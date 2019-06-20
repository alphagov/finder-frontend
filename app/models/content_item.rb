# typed: true
class ContentItem
  def initialize(request_path)
    @request_path = request_path
    @content_item = fetch_content_item
  end

  def as_hash
    @content_item
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

  def sorter_class
    return StatisticsSortPresenter if is_research_and_statistics?

    SortPresenter
  end

  def metadata_class
    return StatisticsMetadataPresenter if is_research_and_statistics?

    MetadataPresenter
  end

  def default_documents_per_page
    content_item.dig('details', 'default_documents_per_page')
  end

  def base_path
    content_item.dig('base_path')
  end

private

  attr_reader :content_item, :request_path

  def is_research_and_statistics?
    base_path == '/search/research-and-statistics'
  end

  def document_type
    content_item['document_type']
  end

  def fetch_content_item
    if development_env_finder_json
      JSON.parse(File.read(development_env_finder_json))
    else
      Services.cached_content_item(request_path)
    end
  end

  # Add a finder with the base path as a key and the finder name
  # without filetype as the value; example:
  # "/review-search/guidance-and-regulation" => "guidance_and_regulation"
  # This allows easy development of finders within finder-frontend
  # *************************************
  # *** THESE SHOULD NOT BE LIVE URLS ***
  # *** AS THEY WILL TAKE PRECEDENCE  ***
  # ***  OVER CONTENT STORE REQUESTS  ***
  # *************************************
  FINDERS_IN_DEVELOPMENT = {
    "/review-search/all" => 'all_content',
    "/review-search/news-and-communications" => 'news_and_communications',
    "/review-search/research-and-statistics" => 'statistics',
  }.freeze

  def development_env_finder_json
    return development_json if is_development_json?

    ENV["DEVELOPMENT_FINDER_JSON"]
  end

  def development_json
    "features/fixtures/#{FINDERS_IN_DEVELOPMENT[request_path]}.json"
  end

  def is_development_json?
    request_path.present? && FINDERS_IN_DEVELOPMENT[request_path].present?
  end
end
