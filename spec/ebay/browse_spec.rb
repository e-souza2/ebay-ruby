# frozen_string_literal: true

RSpec.describe Ebay::Browse do
  let(:client) { Ebay.client }
  let(:browse) { described_class.new(client) }

  before { stub_oauth_token }

  describe "#search" do
    it "searches items by keyword" do
      stub_request(:get, "https://api.ebay.com/buy/browse/v1/item_summary/search")
        .with(query: hash_including(q: "iphone"))
        .to_return(status: 200, body: '{"itemSummaries": []}', headers: { 'Content-Type' => 'application/json' })

      result = browse.search(q: "iphone")
      expect(result).to eq("itemSummaries" => [])
    end

    it "passes additional params" do
      stub_request(:get, "https://api.ebay.com/buy/browse/v1/item_summary/search")
        .with(query: hash_including(q: "iphone", limit: "10"))
        .to_return(status: 200, body: '{"itemSummaries": []}', headers: { 'Content-Type' => 'application/json' })

      browse.search(q: "iphone", limit: "10")
      expect(WebMock).to have_requested(:get, "https://api.ebay.com/buy/browse/v1/item_summary/search")
        .with(query: hash_including(q: "iphone", limit: "10"))
    end
  end

  describe "#get_item" do
    it "retrieves a single item" do
      stub_request(:get, "https://api.ebay.com/buy/browse/v1/item/v1%7C123%7C0")
        .to_return(status: 200, body: '{"itemId": "v1|123|0"}', headers: { 'Content-Type' => 'application/json' })

      result = browse.get_item("v1|123|0")
      expect(result).to eq("itemId" => "v1|123|0")
    end
  end

  describe "#get_items_by_item_group" do
    it "retrieves items by group" do
      stub_request(:get, "https://api.ebay.com/buy/browse/v1/item/get_items_by_item_group")
        .with(query: { item_group_id: "group123" })
        .to_return(status: 200, body: '{"items": []}', headers: { 'Content-Type' => 'application/json' })

      result = browse.get_items_by_item_group("group123")
      expect(result).to eq("items" => [])
    end
  end

  describe "#search_by_image" do
    it "searches by image" do
      stub_request(:post, "https://api.ebay.com/buy/browse/v1/item_summary/search_by_image")
        .to_return(status: 200, body: '{"itemSummaries": []}', headers: { 'Content-Type' => 'application/json' })

      result = browse.search_by_image("base64data")
      expect(result).to eq("itemSummaries" => [])
    end
  end
end
