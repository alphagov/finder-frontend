class ContentItem
  BREXIT_CONTENT_ID = "d6c2de5d-ef90-45d1-82d4-5f2438369eea".freeze

  def initialize(content_item_hash)
    @content_item_hash = content_item_hash.freeze
  end

  def self.from_content_store(base_path)
    content_item_hash = Services.cached_content_item(base_path)
    new(content_item_hash)
  end

  def as_hash
    content_item_hash
  end

  def is_search?
    document_type == "search"
  end

  def is_finder?
    document_type == "finder"
  end

  def is_redirect?
    document_type == "redirect"
  end

  def description
    content_item_hash["description"]
  end

  def links
    content_item_hash["links"]
  end

  def title
    content_item_hash["title"]
  end

  def logo_path
    content_item_hash["details"]["logo_path"]
  end

  def filter
    content_item_hash.dig("details", "filter") || {}
  end

  def open_filter_on_load
    content_item_hash.dig("details", "open_filter_on_load") || ""
  end

  def reject
    content_item_hash.dig("details", "reject") || {}
  end

  def sort_options
    content_item_hash.dig("details", "sort") || []
  end

  def default_order
    content_item_hash["details"]["default_order"] || "-public_timestamp"
  end

  def max_age
    content_item_hash.dig("cache_control", "max_age") || 300
  end

  def cache_public
    public_cache = content_item_hash.dig("cache_control", "public")
    public_cache.nil? ? true : public_cache
  end

  def phase_message
    content_item_hash["details"]["beta_message"] || content_item_hash["details"]["alpha_message"] || ""
  end

  def phase
    content_item_hash["phase"]
  end

  def no_index?
    content_item_hash["details"]["no_index"].present?
  end

  def all_content_finder?
    content_item_hash["content_id"] == "dd395436-9b40-41f3-8157-740a453ac972"
  end

  def related
    related = content_item_hash["links"]["related"] || []
    related.sort_by { |link| link["title"] }
  end

  def show_phase_banner?
    content_item_hash["phase"].in?(%w[alpha beta])
  end

  def document_noun
    content_item_hash["details"]["document_noun"] || ""
  end

  def show_summaries?
    content_item_hash["details"]["show_summaries"]
  end

  def summary
    content_item_hash["details"]["summary"]
  end

  def label_text
    content_item_hash["details"]["label_text"]
  end

  def email_alert_signup
    content_item_hash.dig("links", "email_alert_signup", 0)
  end

  def signup_link
    content_item_hash["details"]["signup_link"]
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
    content_item_hash.dig("details", "default_documents_per_page") || 1500
  end

  def base_path
    content_item_hash["base_path"]
  end

  def raw_facets
    @raw_facets ||= content_item_hash.dig("details", "facets") || []
  end

  def redirect
    content_item_hash.dig("redirects", 0, "destination")
  end

  def organisations
    links.fetch("organisations", [])
  end

  def government?
    base_path.starts_with?("/government")
  end

  def government_content_section
    base_path.split("/")[2]
  end

  def is_licence_transaction?
    base_path == "/find-licences"
  end

private

  attr_reader :content_item_hash

  def is_research_and_statistics?
    base_path == "/search/research-and-statistics"
  end

  def document_type
    content_item_hash["document_type"]
  end
end
