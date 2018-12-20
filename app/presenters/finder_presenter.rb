class FinderPresenter
  include ActionView::Helpers::FormOptionsHelper
  include ActionView::Helpers::UrlHelper

  attr_reader :content_item, :name, :slug, :organisations, :values, :keywords

  def initialize(content_item, values = {})
    @content_item = content_item
    @name = content_item['title']
    @slug = content_item['base_path']
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

  def show_generic_description?
    content_item['details']['generic_description']
  end

  def default_order
    content_item['details']['default_order']
  end

  def document_noun
    content_item['details']['document_noun']
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
    content_item['details']['pagination']
  end

  def email_alert_signup
    if content_item['links']['email_alert_signup']
      content_item['links']['email_alert_signup'].first
    end
  end

  def email_alert_signup_url
    signup_link = content_item['details']['signup_link']
    return signup_link if signup_link.present?

    email_alert_signup['web_url'] if email_alert_signup
  end

  def facets
    @facets ||= FacetCollection.new(
      content_item['details']['facets'].map { |facet|
        FacetParser.parse(facet)
      }
    )
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
    return [] unless sort.present?

    options = Hash[sort.collect { |option| [option['name'], option['name'].parameterize] }]

    disabled_option = keywords.blank? ? relevance_sort_option_value : ''

    selected_option = values['order'] unless values['order'].nil? && sort.detect { |option| option['name'].parameterize == values['order'] }.nil?
    selected_option ||= default_sort_option_value

    options_for_select(options, selected: selected_option, disabled: disabled_option)
  end

  def filter_sentence_fragments
    filters.map(&:sentence_fragment).compact
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
      content_item['details']['results'],
      content_item['details']['total_result_count'],
      self,
    )
  end

  def label_for_metadata_key(key)
    facet = metadata.find { |f| f.key == key }

    facet.short_name || facet.key.humanize
  end

  def display_key_for_metadata_key(key)
    case key
    when 'organisations'
      'title'
    else
      'label'
    end
  end

  def atom_feed_enabled?
    if sort_options.present?
      default_sort_option.blank?
    else
      default_order.blank?
    end
  end

  def atom_url
    ["#{slug}.atom", values.to_query].reject(&:blank?).join("?") if atom_feed_enabled?
  end

  def description
    content_item['description']
  end

private

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
end
