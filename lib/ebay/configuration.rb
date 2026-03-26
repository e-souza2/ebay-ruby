# frozen_string_literal: true

module Ebay
  class Configuration
    attr_accessor :client_id, :client_secret, :app_id,
                  :base_url, :sandbox, :timeout, :marketplace_id

    def initialize
      @base_url = "https://api.ebay.com"
      @sandbox = false
      @timeout = 30
      @marketplace_id = "EBAY_US"
    end

    def sandbox!
      @sandbox = true
      @base_url = "https://api.sandbox.ebay.com"
      self
    end

    def valid?
      !client_id.nil? && !client_id.empty? &&
        !client_secret.nil? && !client_secret.empty?
    end

    def finding_url
      sandbox ? "https://svcs.sandbox.ebay.com/services/search/FindingService/v1" : "https://svcs.ebay.com/services/search/FindingService/v1"
    end
  end
end
