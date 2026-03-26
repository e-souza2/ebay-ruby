# frozen_string_literal: true

RSpec.describe Ebay::Taxonomy do
  let(:client) { Ebay.client }
  let(:taxonomy) { described_class.new(client) }

  before { stub_oauth_token }

  describe "#get_default_category_tree_id" do
    it "returns default category tree id" do
      stub_request(:get, "https://api.ebay.com/commerce/taxonomy/v1/get_default_category_tree_id")
        .with(query: { marketplace_id: "EBAY_US" })
        .to_return(status: 200, body: '{"categoryTreeId": "0", "categoryTreeVersion": "119"}', headers: { 'Content-Type' => 'application/json' })

      result = taxonomy.get_default_category_tree_id
      expect(result).to eq("categoryTreeId" => "0", "categoryTreeVersion" => "119")
    end

    it "accepts custom marketplace_id" do
      stub_request(:get, "https://api.ebay.com/commerce/taxonomy/v1/get_default_category_tree_id")
        .with(query: { marketplace_id: "EBAY_GB" })
        .to_return(status: 200, body: '{"categoryTreeId": "3"}', headers: { 'Content-Type' => 'application/json' })

      result = taxonomy.get_default_category_tree_id("EBAY_GB")
      expect(result).to eq("categoryTreeId" => "3")
    end
  end

  describe "#get_category_tree" do
    it "returns category tree" do
      stub_request(:get, "https://api.ebay.com/commerce/taxonomy/v1/category_tree/0")
        .to_return(status: 200, body: '{"categoryTreeId": "0", "rootCategoryNode": {}}', headers: { 'Content-Type' => 'application/json' })

      result = taxonomy.get_category_tree("0")
      expect(result).to include("categoryTreeId" => "0")
    end
  end

  describe "#get_category_subtree" do
    it "returns category subtree" do
      stub_request(:get, "https://api.ebay.com/commerce/taxonomy/v1/category_tree/0/get_category_subtree")
        .with(query: { category_id: "9355" })
        .to_return(status: 200, body: '{"categorySubtreeNode": {}}', headers: { 'Content-Type' => 'application/json' })

      result = taxonomy.get_category_subtree("0", "9355")
      expect(result).to eq("categorySubtreeNode" => {})
    end
  end
end
