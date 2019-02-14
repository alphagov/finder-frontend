class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :finder, :document_noun, :results, :total

  delegate :document_noun,
           :filters,
           :keywords,
           :atom_url,
           to: :finder

  def initialize(finder, filter_params, view_context)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @filter_params = filter_params
    @view_context = view_context
  end

  def to_hash
    {
      total: number_with_delimiter(total),
      generic_description: generic_description,
      pluralised_document_noun: document_noun.pluralize(total),
      applied_filters: selected_filter_descriptions,
      documents: documents,
      zero_results: total.zero?,
      page_count: documents.count,
      finder_name: finder.name,
      any_filters_applied: any_filters_applied?,
      next_and_prev_links: next_and_prev_links,
      sort_options: sort_options,
    }
  end

  def any_filters_applied?
    selected_filters.length.positive? || keywords.present?
  end

  def generic_description
    publications = "publication".pluralize(total)
    "#{publications} matched your criteria"
  end

  def selected_filter_descriptions
    selected_filters.map { |filter|
      FacetTagPresenter.new(filter.sentence_fragment, filter.value, finder.slug).present
    }.reject(&:empty?)
  end

  def documents
    results.each_with_index.map do |result, index|
      {
        document: SearchResultPresenter.new(result).to_hash,
        document_index: index + 1
      }
    end
  end

  def user_supplied_date(date_facet_key, date_facet_from_to)
    @filter_params.fetch(date_facet_key, {}).fetch(date_facet_from_to, nil)
  end

  def user_supplied_keywords
    @filter_params.fetch('keywords', '')
  end

  def sort_options
    "<span class='visually-hidden'>sorted by <strong>" + sort_option['name'] + "</strong></span>" if sort_option.present?
  end

  def has_email_signup_link?
    signup_links.any?
  end

  def signup_links
    @signup_links ||= fetch_signup_links
  end

private

  attr_reader :view_context

  def next_and_prev_links
    return unless finder.pagination

    current_page = finder.pagination['current_page']
    previous_page = current_page - 1 if current_page > 1
    next_page = current_page + 1 if current_page < finder.pagination['total_pages']
    pages = {}

    pages[:previous_page] = build_page_link("Previous page", previous_page) if previous_page
    pages[:next_page] = build_page_link("Next page", next_page) if next_page

    view_context.render(formats: %w[html], partial: 'govuk_publishing_components/components/previous_and_next_navigation', locals: pages) if pages
  end

  def build_page_link(page_label, page)
    {
      url: [finder.slug, finder.values.merge(page: page).to_query].reject(&:blank?).join("?"),
      title: page_label,
      label: "#{page} of #{finder.pagination['total_pages']}",
    }
  end

  def selected_filters
    (filters + [KeywordFacet.new(keywords)]).select(&:has_filters?)
  end

  def sort_option
    return if finder.sort.blank?

    if @filter_params['order']
      sort_option = finder.sort.detect { |option|
        option['name'].parameterize == @filter_params['order']
      }
    end

    sort_option ||= finder.default_sort_option

    sort_option
  end

  def tagged_to_all?(facet_key, metadata)
    return false unless metadata

    facet = finder.facets.find { |f| f.key == facet_key }
    facet_metadata = metadata.find { |m| m[:id] == facet_key }
    return false unless facet && facet_metadata

    values = facet.allowed_values.map { |v| v['value'] }
    values & facet_metadata[:labels] == values
  end

  def empty_facet_group(key, name)
    { facet_key: key, facet_name: name, documents: [] }
  end

  def facet_label_for(key)
    allowed_values = finder.facets.map(&:allowed_values).flatten
    facet = allowed_values.find { |v| v["value"] == key }
    facet["label"] if facet
  end

  def sort_by_promoted(results)
    results.sort_by { |r| r[:document][:promoted] ? 0 : 1 }
  end

  def sort_by_promoted_alphabetical(search_results)
    sorted_results = search_results.sort_by { |r| r[:document][:title] }
    sort_by_promoted(sorted_results)
  end

  def compact_and_sort(group)
    group = group.reject { |_, v| v[:documents].empty? }
    group.values.sort_by { |g| g[:facet_name] }
  end

  def facet_filters
    @filter_params.symbolize_keys.without(:order, :keywords)
  end

  def fetch_signup_links
    links = {}
    links[:email_signup_link] = email_signup_link if email_signup_link.present?
    links[:feed_link] = feed_link if feed_link.present?
    links[:margin_bottom] = 5 if email_signup_link.present? || feed_link.present?
    links
  end

  def email_signup_link
    return '' unless finder.respond_to?(:email_alert_signup_url)

    finder.email_alert_signup_url
  end

  def feed_link
    return '' unless finder.respond_to?(:atom_url)

    finder.atom_url
  end
end
