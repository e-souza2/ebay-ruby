# frozen_string_literal: true

RSpec.describe Ebay::Finding do
  let(:client) { Ebay.client }
  let(:finding) { described_class.new(client) }
  let(:finding_url) { "https://svcs.ebay.com/services/search/FindingService/v1" }

  before do
    stub_oauth_token
  end

  describe "#find_items_by_keywords" do
    it "searches by keywords" do
      stub_request(:get, finding_url)
        .with(query: hash_including("OPERATION-NAME" => "findItemsByKeywords", "keywords" => "laptop"))
        .to_return(status: 200, body: '{"findItemsByKeywordsResponse": []}', headers: { 'Content-Type' => 'application/json' })

      result = finding.find_items_by_keywords("laptop")
      expect(result).to eq("findItemsByKeywordsResponse" => [])
    end

    it "includes correct service params" do
      stub_request(:get, finding_url)
        .with(query: hash_including(
          "OPERATION-NAME" => "findItemsByKeywords",
          "SERVICE-VERSION" => "1.0.0",
          "SECURITY-APPNAME" => "test_app_id",
          "RESPONSE-DATA-FORMAT" => "JSON"
        ))
        .to_return(status: 200, body: '{}', headers: { 'Content-Type' => 'application/json' })

      finding.find_items_by_keywords("test")
    end
  end

  describe "#find_completed_items" do
    it "searches completed/sold items" do
      stub_request(:get, finding_url)
        .with(query: hash_including("OPERATION-NAME" => "findCompletedItems", "keywords" => "vintage watch"))
        .to_return(status: 200, body: '{"findCompletedItemsResponse": []}', headers: { 'Content-Type' => 'application/json' })

      result = finding.find_completed_items("vintage watch")
      expect(result).to eq("findCompletedItemsResponse" => [])
    end
  end

  describe "#find_items_advanced" do
    it "performs advanced search" do
      stub_request(:get, finding_url)
        .with(query: hash_including("OPERATION-NAME" => "findItemsAdvanced"))
        .to_return(status: 200, body: '{"findItemsAdvancedResponse": []}', headers: { 'Content-Type' => 'application/json' })

      result = finding.find_items_advanced(keywords: "shoes", categoryId: "3034")
      expect(result).to eq("findItemsAdvancedResponse" => [])
    end
  end

  describe "#find_items_by_category" do
    it "searches by category" do
      stub_request(:get, finding_url)
        .with(query: hash_including("OPERATION-NAME" => "findItemsByCategory", "categoryId" => "9355"))
        .to_return(status: 200, body: '{"findItemsByCategoryResponse": []}', headers: { 'Content-Type' => 'application/json' })

      result = finding.find_items_by_category("9355")
      expect(result).to eq("findItemsByCategoryResponse" => [])
    end
  end

  describe "error handling" do
    it "raises APIError on failure" do
      stub_request(:get, finding_url)
        .with(query: hash_including("OPERATION-NAME" => "findItemsByKeywords"))
        .to_return(status: 500, body: "Server Error")

      expect { finding.find_items_by_keywords("test") }.to raise_error(Ebay::APIError)
    end
  end
end
