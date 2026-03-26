# frozen_string_literal: true

RSpec.describe Ebay::Configuration do
  subject(:config) { described_class.new }

  describe "#initialize" do
    it "sets default base_url" do
      expect(config.base_url).to eq("https://api.ebay.com")
    end

    it "sets default sandbox to false" do
      expect(config.sandbox).to be false
    end

    it "sets default timeout to 30" do
      expect(config.timeout).to eq(30)
    end

    it "sets default marketplace_id" do
      expect(config.marketplace_id).to eq("EBAY_US")
    end
  end

  describe "#sandbox!" do
    it "enables sandbox mode" do
      config.sandbox!
      expect(config.sandbox).to be true
    end

    it "changes base_url to sandbox" do
      config.sandbox!
      expect(config.base_url).to eq("https://api.sandbox.ebay.com")
    end

    it "returns self for chaining" do
      expect(config.sandbox!).to eq(config)
    end
  end

  describe "#valid?" do
    it "returns false when client_id is nil" do
      config.client_secret = "secret"
      expect(config.valid?).to be false
    end

    it "returns false when client_secret is nil" do
      config.client_id = "id"
      expect(config.valid?).to be false
    end

    it "returns false when client_id is empty" do
      config.client_id = ""
      config.client_secret = "secret"
      expect(config.valid?).to be false
    end

    it "returns true when both are set" do
      config.client_id = "id"
      config.client_secret = "secret"
      expect(config.valid?).to be true
    end
  end

  describe "#finding_url" do
    it "returns production URL by default" do
      expect(config.finding_url).to eq("https://svcs.ebay.com/services/search/FindingService/v1")
    end

    it "returns sandbox URL when sandbox enabled" do
      config.sandbox!
      expect(config.finding_url).to eq("https://svcs.sandbox.ebay.com/services/search/FindingService/v1")
    end
  end
end
