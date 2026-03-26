# frozen_string_literal: true

RSpec.describe Ebay::Client do
  let(:client) { Ebay.client }

  describe "#initialize" do
    it "raises ConfigurationError without valid config" do
      Ebay.reset!
      Ebay.configure { |c| c.client_id = nil }
      expect { Ebay.client }.to raise_error(Ebay::ConfigurationError)
    end
  end

  describe "#authenticate!" do
    it "obtains an access token" do
      stub_oauth_token
      token = client.authenticate!
      expect(token).to eq("test_token")
    end

    it "sends correct authorization header" do
      stub_oauth_token
      client.authenticate!

      expected_credentials = Base64.strict_encode64("test_client_id:test_client_secret")
      expect(WebMock).to have_requested(:post, "https://api.ebay.com/identity/v1/oauth2/token")
        .with(headers: { 'Authorization' => "Basic #{expected_credentials}" })
    end

    it "raises AuthenticationError on failure" do
      stub_request(:post, "https://api.ebay.com/identity/v1/oauth2/token")
        .to_return(status: 401, body: "Unauthorized")

      expect { client.authenticate! }.to raise_error(Ebay::AuthenticationError)
    end
  end

  describe "#get" do
    before { stub_oauth_token }

    it "makes authenticated GET requests" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 200, body: '{"result": "ok"}', headers: { 'Content-Type' => 'application/json' })

      result = client.get("/test")
      expect(result).to eq("result" => "ok")
    end

    it "passes query params" do
      stub_request(:get, "https://api.ebay.com/test?q=shoes")
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      client.get("/test", q: "shoes")
      expect(WebMock).to have_requested(:get, "https://api.ebay.com/test").with(query: { q: "shoes" })
    end

    it "auto-authenticates before request" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      client.get("/test")
      expect(WebMock).to have_requested(:post, "https://api.ebay.com/identity/v1/oauth2/token").once
    end
  end

  describe "#post" do
    before { stub_oauth_token }

    it "makes authenticated POST requests" do
      stub_request(:post, "https://api.ebay.com/test")
        .to_return(status: 200, body: '{"created": true}', headers: { 'Content-Type' => 'application/json' })

      result = client.post("/test", { name: "item" })
      expect(result).to eq("created" => true)
    end
  end

  describe "error handling" do
    before { stub_oauth_token }

    it "raises NotFoundError on 404" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 404, body: "Not Found")

      expect { client.get("/test") }.to raise_error(Ebay::NotFoundError)
    end

    it "raises RateLimitError on 429" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 429, body: "Too Many Requests", headers: { 'retry-after' => '60' })

      expect { client.get("/test") }.to raise_error(Ebay::RateLimitError) do |error|
        expect(error.retry_after).to eq('60')
      end
    end

    it "raises ValidationError on 400" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 400, body: '{"message": "Bad Request"}', headers: { 'Content-Type' => 'application/json' })

      expect { client.get("/test") }.to raise_error(Ebay::ValidationError)
    end

    it "raises APIError on 500" do
      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 500, body: "Internal Server Error")

      expect { client.get("/test") }.to raise_error(Ebay::APIError)
    end
  end

  describe "token caching" do
    it "reuses token for multiple requests" do
      stub_oauth_token

      stub_request(:get, "https://api.ebay.com/test")
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      client.get("/test")
      client.get("/test")

      expect(WebMock).to have_requested(:post, "https://api.ebay.com/identity/v1/oauth2/token").once
    end
  end
end
