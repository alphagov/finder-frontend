class Services::ContentStore
  def hard_refresh_cache
    finder_paths.map do |base_path|
      item = content_item(base_path)
      Rails.cache.write(cache_key(base_path), item)
    end
  end

  def soft_refresh_cache
    finder_paths.map do |base_path|
      cached_content_item(base_path)
    end
  end

  def cached_content_item(base_path)
    Rails.cache.fetch(cache_key(base_path)) do
      content_item(base_path)
    end
  end

  def cache_key(base_path)
    "finder-frontend_content_items#{base_path}"
  end

private

  def content_item(base_path)
    GovukStatsd.time("content_store.fetch_request_time") do
      content_store.content_item(base_path).to_h
    end
  rescue GdsApi::HTTPServerError, GdsApi::HTTPBadGateway
    GovukStatsd.increment("content_store_service.connection_error")
    raise
  end

  def content_store
    GdsApi::ContentStore.new(Plek.find("content-store"))
  end

  def finder_paths
    FetchFinders.from_search_api.map { |result| result['link'] }.compact
  end
end
