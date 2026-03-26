# frozen_string_literal: true

module Ebay
  class Error < StandardError; end

  class ConfigurationError < Error
    def initialize(message = "Missing required configuration: client_id and client_secret")
      super(message)
    end
  end

  class AuthenticationError < Error
    def initialize(message = "Authentication failed")
      super(message)
    end
  end

  class APIError < Error
    attr_reader :status_code, :response_body

    def initialize(message, status_code = nil, response_body = nil)
      super(message)
      @status_code = status_code
      @response_body = response_body
    end
  end

  class ValidationError < APIError
    attr_reader :errors

    def initialize(message, status_code = nil, response_body = nil, errors = {})
      super(message, status_code, response_body)
      @errors = errors
    end
  end

  class NotFoundError < APIError
    def initialize(message = "Resource not found", status_code = 404, response_body = nil)
      super(message, status_code, response_body)
    end
  end

  class RateLimitError < APIError
    attr_reader :retry_after

    def initialize(message = "Rate limit exceeded", status_code = 429, response_body = nil, retry_after = nil)
      super(message, status_code, response_body)
      @retry_after = retry_after
    end
  end
end
