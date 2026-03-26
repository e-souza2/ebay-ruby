# frozen_string_literal: true

module Ebay
  class Taxonomy < Base
    def get_default_category_tree_id(marketplace_id = nil)
      mid = marketplace_id || client.configuration.marketplace_id
      client.get("/commerce/taxonomy/v1/get_default_category_tree_id", marketplace_id: mid)
    end

    def get_category_tree(category_tree_id)
      client.get("/commerce/taxonomy/v1/category_tree/#{category_tree_id}")
    end

    def get_category_subtree(category_tree_id, category_id)
      client.get("/commerce/taxonomy/v1/category_tree/#{category_tree_id}/get_category_subtree", category_id: category_id)
    end
  end
end
