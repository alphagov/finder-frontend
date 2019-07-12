class ContentItem
  def initialize(content_item_hash)
    @content_item_hash = content_item_hash
  end

  def self.from_content_store(base_path)
    content_item_hash = Services.cached_content_item(base_path)
    self.new(content_item_hash)
  end

  def as_hash
    content_item_hash
  end

  def is_search?
    document_type == 'search'
  end

  def is_finder?
    document_type == 'finder'
  end

  def is_redirect?
    document_type == 'redirect'
  end

  def title
    content_item_hash['title']
  end

  def filter
    content_item_hash.dig('details', 'filter') || {}
  end

  def reject
    content_item_hash.dig('details', 'reject') || {}
  end

  def sort_options
    content_item_hash.dig('details', 'sort') || []
  end

  def default_order
    content_item_hash['details']['default_order'] || "-public_timestamp"
  end

  def sorter_class
    return StatisticsSortPresenter if is_research_and_statistics?

    SortPresenter
  end

  def metadata_class
    return StatisticsMetadataPresenter if is_research_and_statistics?

    MetadataPresenter
  end

  def default_documents_per_page
    content_item_hash.dig('details', 'default_documents_per_page') || 1500
  end

  def base_path
    content_item_hash.dig('base_path')
  end

  def raw_facets
    @raw_facets ||= FacetExtractor.new(content_item_hash).extract
  end

  def redirect
    content_item_hash.dig('redirects', 0, 'destination')
  end

private

  attr_reader :content_item_hash

  def is_research_and_statistics?
    base_path == '/search/research-and-statistics'
  end

  def document_type
    content_item_hash['document_type']
  end
end
