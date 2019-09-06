require 'spec_helper'
require 'gds_api/test_helpers/content_store'
require 'gds_api/test_helpers/search'

module ContentStoreServiceHelper
  include GdsApi::TestHelpers::ContentStore
  include GdsApi::TestHelpers::Search

  def expect_item_to_be_in_cache(base_path)
    expect(cached_item(base_path)).to eq(content_item(base_path))
  end

  def cached_item(base_path)
    Rails.cache.fetch described_class.new.cache_key(base_path)
  end

  def content_item(base_path)
    content_item_for_base_path(base_path)
  end

  def stub_content_store_has_finders
    finder_content_items.each do |item|
      path = item[:link]
      stub_content_store_has_item(path, content_item(path))
    end
  end

  def finder_content_items
    [
      { link: '/search/all' },
      { link: '/breakfast-finder' },
      { link: '/lunch-finder' },
      { link: '/dinner-finder' },
    ]
  end

  def search_api_has_finders
    stub_any_search.to_return(body: { results: finder_content_items }.to_json)
  end

  def search_api_isnt_available
    stub_any_search.to_return(status: 503)
  end

  def content_items_are_already_cached
    finder_content_items.each do |item|
      base_path = item[:link]
      content = content_item(base_path)
      Rails.cache.write("finder-frontend_content_items#{base_path}", content)
    end
  end
end
