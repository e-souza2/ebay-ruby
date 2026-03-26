# frozen_string_literal: true

module Ebay
  class Finding < Base
    def find_items_by_keywords(keywords, **params)
      finding_request("findItemsByKeywords", { keywords: keywords }.merge(params))
    end

    def find_completed_items(keywords, **params)
      finding_request("findCompletedItems", { keywords: keywords }.merge(params))
    end

    def find_items_advanced(**params)
      finding_request("findItemsAdvanced", params)
    end

    def find_items_by_category(category_id, **params)
      finding_request("findItemsByCategory", { categoryId: category_id }.merge(params))
    end

    private

    def finding_request(operation, params)
      url = client.configuration.finding_url
      query = {
        "OPERATION-NAME" => operation,
        "SERVICE-VERSION" => "1.0.0",
        "SECURITY-APPNAME" => client.configuration.app_id || client.configuration.client_id,
        "RESPONSE-DATA-FORMAT" => "JSON",
        "REST-PAYLOAD" => ""
      }.merge(params)

      response = HTTParty.get(url, query: query, timeout: client.configuration.timeout)
      handle_finding_response(response, operation)
    end

    def handle_finding_response(response, operation)
      return response.parsed_response unless response.code >= 400
      raise APIError.new("Finding API error", response.code, response.body)
    end
  end
end
