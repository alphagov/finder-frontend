class FinderPresenter
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper

  attr_reader :content_item, :organisations, :values, :keywords, :links, :facets

  delegate :hide_facets_by_default,
           :show_summaries?,
           :document_noun,
           :default_order,
           :show_phase_banner?,
           :links,
           :phase_message,
           :phase,
           :filter,
           :logo_path,
           :related,
           :summary,
           :email_alert_signup,
           :description,
           :no_index?,
           :canonical_link?,
           :all_content_finder?,
           :eu_exit_finder?, to: :content_item


  def initialize(content_item, search_results, values = {})
    @content_item = content_item
    @search_results = search_results
    @organisations = content_item.links.fetch('organisations', [])
    @values = values
    @facet_hashes = facet_hashes(@content_item)
    @facets = facet_collection(@facet_hashes, @values)
    @keywords = values["keywords"].presence
  end

  def name
    content_item.title
  end

  def slug
    content_item.base_path
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

  def page_metadata
    metadata = {
      from: organisations
    }

    metadata[:inverse] = true if topic_finder?
    metadata.reject { |_, links| links.blank? }
  end

  def results
    @results ||= ResultSetParser.parse(
      search_results.fetch("results"),
      search_results.fetch("total"),
      self,
    )
  end

  def start_offset
    search_results.fetch('start', 0) + 1
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

  def email_alert_signup_url
    signup_link = content_item.signup_link
    return signup_link if signup_link.present?

    "#{email_alert_signup['web_url']}#{alert_query_string}" if email_alert_signup
  end

  def topic_finder?
    values.include?('topic') && topic_finder_parent.present?
  end

  def topic_finder_parent
    Services.registries.all['full_topic_taxonomy'][values['topic']]
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

  def facet_hashes(content_item)
    FacetExtractor.new(content_item).extract
  end

  def facet_collection(facet_hashes, value_hashes)
    FacetCollection.new(
      facet_hashes,
      value_hashes
    )
  end
end
