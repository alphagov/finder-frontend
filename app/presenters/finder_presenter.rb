class FinderPresenter
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper

  attr_reader :content_item, :name, :slug, :organisations, :values, :keywords, :links, :facets

  def initialize(content_item, search_results, values = {})
    @content_item = content_item
    @search_results = search_results
    @name = content_item['title']
    @slug = content_item['base_path']
    @links = content_item['links']
    @organisations = content_item['links'].fetch('organisations', [])
    @values = values
    @facet_hashes = facet_hashes(@content_item)
    @facets = facet_collection(@facet_hashes, @values)
    @keywords = values["keywords"].presence
  end

  def phase_message
    message = content_item['details']['beta_message'] || content_item['details']['alpha_message'] || ""

    message.html_safe
  end

  def phase
    content_item['phase']
  end

  def show_phase_banner?
    content_item['phase'].in?(%w[alpha beta])
  end

  def default_order
    content_item['details']['default_order']
  end

  def document_noun
    content_item['details']['document_noun'] || ""
  end

  def hide_facets_by_default
    content_item['details']['hide_facets_by_default'] || false
  end

  def filter
    content_item['details']['filter']
  end

  def logo_path
    content_item['details']['logo_path']
  end

  def summary
    content_item['details']['summary']
  end

  def email_alert_signup
    if content_item['links']['email_alert_signup']
      content_item['links']['email_alert_signup'].first
    end
  end

  def email_alert_signup_url
    signup_link = content_item['details']['signup_link']
    return signup_link if signup_link.present?

    "#{email_alert_signup['web_url']}#{alert_query_string}" if email_alert_signup
  end

  def facet_details_lookup
    @facet_details_lookup ||= begin
      result_hashes = @facet_hashes.map do |facet|
        facet_name = facet.fetch('short_name', facet['name'])
        facet_key = facet['key']
        facet.fetch('allowed_values', []).to_h do |value|
          [value['content_id'], {
            id: facet_key,
            name: facet_name,
            key: facet_key,
            type: 'content_id'
          }]
        end
      end
      result_hashes.reduce({}, :merge)
    end
  end

  def facet_value_lookup
    @facet_value_lookup ||= begin
      facet_values = @facet_hashes.map { |f| f['allowed_values'] || [] }
      @facet_value_lookup = facet_values.flatten.to_h do |val|
        [val['content_id'], val['value']]
      end
    end
  end

  def filters
    facets.filters
  end

  def government?
    slug.starts_with?("/government")
  end

  def government_content_section
    slug.split('/')[2]
  end

  def display_metadata?
    !eu_exit_finder?
  end

  def metadata
    facets.metadata
  end

  def date_metadata_keys
    metadata.select { |f| f.type == "date" }.map(&:key)
  end

  def text_metadata_keys
    metadata.select { |f| f.type == "text" }.map(&:key)
  end

  def show_keyword_search?
    keywords.present? || facets.any? || results.total.positive?
  end

  def show_summaries?
    content_item['details']['show_summaries']
  end

  def page_metadata
    metadata = {
      from: organisations,
    }

    metadata.reject { |_, links| links.blank? }
  end

  def related
    related = content_item['links']['related'] || []
    related.sort_by { |link| link['title'] }
  end

  def results
    @results ||= ResultSetParser.parse(
      search_results.fetch("results"),
      search_results.fetch("total"),
      self,
    )
  end

  def label_for_metadata_key(key)
    facet = metadata.find { |f| f.key == key }

    facet.short_name || facet.key.humanize
  end

  def display_key_for_metadata_key(key)
    if %w[organisations document_collections].include?(key)
      'title'
    else
      'label'
    end
  end

  def atom_url
    "#{slug}.atom#{alert_query_string}"
  end

  def description
    content_item['description']
  end

  def no_index?
    !!content_item["details"]["no_index"]
  end

  def canonical_link?
    content_item['details']['canonical_link']
  end

  def all_content_finder?
    self.content_item['content_id'] == 'dd395436-9b40-41f3-8157-740a453ac972'
  end

  def topic_finder?
    values.include?('topic-finder')
  end

  # FIXME: This should be removed once we have a way to determine
  # whether to display metadata in the finder definition
  def eu_exit_finder?
    EuExitFinderHelper.eu_exit_finder? self.content_item['content_id']
  end

private

  attr_reader :search_results

  def is_external?(href)
    URI.parse(href).host != "www.gov.uk"
  end

  def alert_query_string
    facets_with_filters = facets.select(&:has_filters?)
    query_params_array = facets_with_filters.map(&:query_params)
    query_string = query_params_array.inject({}, :merge).to_query
    query_string.blank? ? query_string : "?#{query_string}"
  end

  def facet_hashes(content_item_hash)
    FacetExtractor.for(content_item_hash).extract
  end

  def facet_collection(facet_hashes, value_hashes)
    FacetCollection.new(
      facet_hashes,
      value_hashes
    )
  end
end
