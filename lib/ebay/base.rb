# frozen_string_literal: true

module Ebay
  class Base
    attr_reader :client

    def initialize(client = nil)
      @client = client || Ebay.client
    end
  end
end
