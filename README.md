# ebay-ruby

A modern Ruby gem for the eBay REST APIs. Supports the Browse API, Finding API, and Taxonomy API with OAuth 2.0 authentication.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'ebay-ruby'
```

And then execute:

```bash
bundle install
```

Or install it yourself:

```bash
gem install ebay-ruby
```

## Configuration

```ruby
require 'ebay'

Ebay.configure do |config|
  config.client_id = ENV['EBAY_CLIENT_ID']
  config.client_secret = ENV['EBAY_CLIENT_SECRET']
  config.app_id = ENV['EBAY_APP_ID']           # Optional, defaults to client_id for Finding API
  config.marketplace_id = 'EBAY_US'             # Default
  config.timeout = 30                            # Default
end
```

### Sandbox Mode

```ruby
Ebay.configure do |config|
  config.client_id = ENV['EBAY_SANDBOX_CLIENT_ID']
  config.client_secret = ENV['EBAY_SANDBOX_CLIENT_SECRET']
  config.sandbox!
end
```

## Usage

### Browse API

Search for items, get item details, and search by image.

```ruby
browse = Ebay::Browse.new

# Search items
results = browse.search(q: "vintage rolex", limit: 10)
results['itemSummaries'].each do |item|
  puts "#{item['title']} - #{item['price']['value']} #{item['price']['currency']}"
end

# Get a specific item
item = browse.get_item("v1|123456789|0")

# Get items by group
items = browse.get_items_by_item_group("group123")

# Search by image
results = browse.search_by_image(Base64.encode64(File.read("watch.jpg")))
```

### Finding API

Search active and completed/sold listings. Uses the legacy Finding Service (no OAuth required, just app_id).

```ruby
finding = Ebay::Finding.new

# Search by keywords
results = finding.find_items_by_keywords("macbook pro m3")

# Find completed/sold items (great for price history)
sold = finding.find_completed_items("pokemon base set charizard")

# Advanced search with filters
results = finding.find_items_advanced(keywords: "nike jordan", categoryId: "93427")

# Search by category
results = finding.find_items_by_category("9355")
```

### Taxonomy API

Get category trees and browse category hierarchies.

```ruby
taxonomy = Ebay::Taxonomy.new

# Get default category tree ID for a marketplace
tree_info = taxonomy.get_default_category_tree_id("EBAY_US")
tree_id = tree_info['categoryTreeId']

# Get the full category tree
tree = taxonomy.get_category_tree(tree_id)

# Get a subtree
subtree = taxonomy.get_category_subtree(tree_id, "9355")
```

### Authentication

The gem handles OAuth 2.0 Client Credentials authentication automatically. Tokens are cached and refreshed when expired.

```ruby
client = Ebay.client

# Manual authentication (usually not needed)
client.authenticate!

# Direct API calls
result = client.get("/buy/browse/v1/item_summary/search", q: "test")
result = client.post("/some/endpoint", { data: "value" })
```

## Error Handling

```ruby
begin
  browse.search(q: "test")
rescue Ebay::AuthenticationError => e
  puts "Auth failed: #{e.message}"
rescue Ebay::NotFoundError => e
  puts "Not found: #{e.message} (#{e.status_code})"
rescue Ebay::RateLimitError => e
  puts "Rate limited. Retry after: #{e.retry_after}"
rescue Ebay::ValidationError => e
  puts "Validation error: #{e.errors}"
rescue Ebay::APIError => e
  puts "API error: #{e.message} (#{e.status_code})"
rescue Ebay::ConfigurationError => e
  puts "Config error: #{e.message}"
end
```

## Development

```bash
git clone https://github.com/esouza/ebay-ruby.git
cd ebay-ruby
bundle install
bundle exec rspec
```

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/esouza/ebay-ruby. See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

The gem is available as open source under the terms of the [MIT License](LICENSE.txt).
