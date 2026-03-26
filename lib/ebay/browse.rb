# frozen_string_literal: true

require 'uri'

module Ebay
  class Browse < Base
    def search(q:, **params)
      client.get("/buy/browse/v1/item_summary/search", { q: q }.merge(params))
    end

    def get_item(item_id)
      client.get("/buy/browse/v1/item/#{URI.encode_www_form_component(item_id)}")
    end

    def get_items_by_item_group(item_group_id)
      client.get("/buy/browse/v1/item/get_items_by_item_group", item_group_id: item_group_id)
    end

    def search_by_image(image_base64, **params)
      client.post("/buy/browse/v1/item_summary/search_by_image", { image: image_base64 }.merge(params))
    end
  end
end
