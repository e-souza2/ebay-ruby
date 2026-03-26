# frozen_string_literal: true

module Ebay
  class Client
    include HTTParty

    attr_reader :configuration

    def initialize(configuration = nil)
      @configuration = configuration || Ebay.configuration
      @access_token = nil
      @token_expires_at = nil
      validate_configuration!
    end

    def authenticate!
      credentials = Base64.strict_encode64("#{configuration.client_id}:#{configuration.client_secret}")

      response = self.class.post(
        "#{configuration.base_url}/identity/v1/oauth2/token",
        headers: {
          'Authorization' => "Basic #{credentials}",
          'Content-Type' => 'application/x-www-form-urlencoded'
        },
        body: "grant_type=client_credentials&scope=https://api.ebay.com/oauth/api_scope",
        timeout: configuration.timeout
      )

      case response.code
      when 200
        data = response.parsed_response
        @access_token = data['access_token']
        @token_expires_at = Time.now + (data['expires_in'] || 7200).to_i - 60
        @access_token
      else
        raise AuthenticationError, "OAuth token request failed: #{response.body}"
      end
    end

    def get(path, params = {})
      request(:get, path, query: params)
    end

    def post(path, data = {})
      request(:post, path, body: data.to_json)
    end

    private

    def validate_configuration!
      raise ConfigurationError unless configuration&.valid?
    end

    def ensure_authenticated!
      if @access_token.nil? || @token_expires_at.nil? || Time.now >= @token_expires_at
        authenticate!
      end
    end

    def request(method, path, options = {})
      ensure_authenticated!

      url = "#{configuration.base_url}#{path}"
      request_options = {
        headers: default_headers,
        timeout: configuration.timeout
      }

      if options[:query] && !options[:query].empty?
        request_options[:query] = options[:query]
      end

      if options[:body]
        request_options[:body] = options[:body]
      end

      response = self.class.send(method, url, request_options)
      handle_response(response)
    end

    def default_headers
      {
        'Authorization' => "Bearer #{@access_token}",
        'Content-Type' => 'application/json',
        'Accept' => 'application/json'
      }
    end

    def handle_response(response)
      case response.code
      when 200, 201, 202, 204
        response.parsed_response
      when 401
        raise AuthenticationError, "Authentication failed: #{response.body}"
      when 404
        raise NotFoundError.new("Resource not found", response.code, response.body)
      when 429
        retry_after = response.headers['retry-after']
        raise RateLimitError.new("Rate limit exceeded", response.code, response.body, retry_after)
      when 400, 422
        parsed = response.parsed_response || {}
        errors = parsed['errors'] || parsed['message'] || {}
        raise ValidationError.new(
          parsed['message'] || 'Validation failed',
          response.code,
          response.body,
          errors
        )
      when 500..599
        raise APIError.new("Server error", response.code, response.body)
      else
        raise APIError.new("Unexpected response", response.code, response.body)
      end
    end
  end
end
