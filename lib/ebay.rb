# frozen_string_literal: true

require 'httparty'
require 'json'
require 'base64'

require_relative 'ebay/version'
require_relative 'ebay/errors'
require_relative 'ebay/configuration'
require_relative 'ebay/client'
require_relative 'ebay/base'
require_relative 'ebay/browse'
require_relative 'ebay/finding'
require_relative 'ebay/taxonomy'

module Ebay
  class << self
    attr_accessor :configuration

    def configure
      self.configuration ||= Configuration.new
      yield(configuration) if block_given?
    end

    def client
      @client ||= Client.new(configuration)
    end

    def reset!
      @client = nil
      @configuration = nil
    end
  end
end
