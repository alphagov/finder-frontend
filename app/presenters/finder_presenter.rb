class FinderPresenter
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper

  attr_reader :content_item, :name, :slug, :organisations, :values, :keywords, :links

  MOST_RECENT_FIRST = "-public_timestamp".freeze

  def initialize(content_item, search_results, values = {})
    @content_item = content_item
    @search_results = search_results
    @name = content_item['title']
    @slug = content_item['base_path']
    @links = content_item['links']
    @organisations = content_item['links'].fetch('organisations', [])
    @values = values
    facets.values = values
    @keywords = values["keywords"].presence
  end

  def phase_message
    content_item['details']['beta_message'] || content_item['details']['alpha_message']
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
    content_item['details']['document_noun']
  end

  def hide_facets_by_default
    content_item['details']['hide_facets_by_default'] || false
  end

  def human_readable_finder_format
    content_item['details']['human_readable_finder_format']
  end

  def filter
    content_item['details']['filter']
  end

  def sort
    content_item['details']['sort']
  end

  def logo_path
    content_item['details']['logo_path']
  end

  def summary
    content_item['details']['summary']
  end

  def pagination
    documents_per_page = content_item['details']['default_documents_per_page']

    return nil unless documents_per_page

    start_offset = search_results['start']
    total_results = search_results['total']

    {
      'current_page' => (start_offset / documents_per_page) + 1,
      'total_pages' => (total_results / documents_per_page.to_f).ceil,
    }
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

  def facets
    @facets ||= FacetCollection.new(
      raw_facets.map do |facet|
        FacetParser.parse(facet)
      end
    )
  end

  def raw_facets
    @raw_facets ||= FacetExtractor.for(content_item).extract
  end

  def facet_details_lookup
    return @facet_details_lookup if @facet_details_lookup

    facet_hases = raw_facets.map do |facet|
      facet_name = facet['name']
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
    @facet_details_lookup = facet_hases.reduce({}, :merge)
  end

  def facet_value_lookup
    return @facet_value_lookup if @facet_value_lookup

    facet_values = raw_facets.map { |f| f['allowed_values'] || [] }
    @facet_value_lookup = facet_values.flatten.to_h do |val|
      [val['content_id'], val['value']]
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
    !eu_exit_finder
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

  def default_sort_option
    sort
      &.detect { |option| option['default'] }
  end

  def default_sort_option_value
    default_sort_option
      &.dig('name')
      &.parameterize
  end

  def default_sort_option_key
    default_sort_option
      &.dig('key')
  end

  def relevance_sort_option
    sort
      &.detect { |option| %w(relevance -relevance).include?(option['key']) }
  end

  def relevance_sort_option_value
    relevance_sort_option
      &.dig('name')
      &.parameterize
  end

  def sort_options
    return [] if sort.blank?

    options = sort.collect do |option|
      [
        option['name'],
        option['name'].parameterize,
        {
          'data-track-category' => 'dropDownClicked',
          'data-track-action' => 'clicked',
          'data-track-label' => option['name']
        }
      ]
    end

    disabled_option = keywords.blank? ? relevance_sort_option_value : ''

    selected_option = if values['order'].present? && sort.any? { |option| option['name'].parameterize == values['order'] }
                        values['order']
                      else
                        default_sort_option_value
                      end

    options_for_select(options, selected: selected_option, disabled: disabled_option)
  end

  def show_keyword_search?
    keywords.present? || facets.any? || results.total.positive?
  end

  def show_summaries?
    content_item['details']['show_summaries']
  end

  def page_metadata
    metadata = {
      part_of: part_of,
      from: from,
      other: other,
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

  def atom_feed_enabled?
    if sort_options.present?
      default_sort_option.blank? || default_sort_option_key == MOST_RECENT_FIRST
    else
      default_order.blank? || default_order == MOST_RECENT_FIRST
    end
  end

  def atom_url
    "#{slug}.atom#{alert_query_string}" if atom_feed_enabled?
  end

  def description
    content_item['description']
  end

  def canonical_link?
    content_item['details']['canonical_link']
  end

private

  attr_reader :search_results

  def part_of
    content_item['links']['part_of'] || []
  end

  def people
    content_item['links']['people'] || []
  end

  def working_groups
    content_item['links']['working_groups'] || []
  end

  def from
    organisations + people + working_groups
  end

  def other
    if applicable_nations_html_fragment
      { "Applies to" => applicable_nations_html_fragment }
    end
  end

  def applicable_nations_html_fragment
    nation_applicability = content_item['details']['nation_applicability']
    if nation_applicability
      applies_to = nation_applicability['applies_to'].map(&:titlecase)
      alternative_policies = nation_applicability['alternative_policies'].map do |alternative|
        link_to(alternative['nation'].titlecase, alternative['alt_policy_url'], ({ rel: 'external' } if is_external?(alternative['alt_policy_url'])))
      end
      if alternative_policies.any?
        "#{applies_to.to_sentence} (see policy for #{alternative_policies.to_sentence})".html_safe
      else
        applies_to.to_sentence
      end
    end
  end

  def is_external?(href)
    URI.parse(href).host != "www.gov.uk"
  end

  def alert_query_string
    facets_with_filters = facets.select(&:has_filters?)

    facets_with_values = facets_with_filters.reject { |facet|
      facet.value.nil? ||
        facet.value.is_a?(Hash) && facet.value.values.all?(&:blank?) ||
        facet.value.is_a?(Array) && facet.value.empty?
    }

    filtered_values = facets_with_values.each_with_object({}) { |facet, hash|
      hash[facet.key] = facet.value
    }

    query_string = filtered_values.to_query
    query_string.blank? ? query_string : "?#{query_string}"
  end

  # FIXME: This should be removed once we have a way to determine
  # whether to display metadata in the finder definition
  def eu_exit_finder
    slug == "/find-eu-exit-guidance-business"
  end
end
