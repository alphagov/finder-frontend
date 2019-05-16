class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :finder, :results, :total, :pluralised_document_noun

  delegate :filters,
           :keywords,
           :atom_url,
           to: :finder

  def initialize(finder, filter_params, view_context, sort_presenter, metadata_presenter_class, show_top_result = false)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @pluralised_document_noun = finder.document_noun.pluralize(total)
    @filter_params = filter_params
    @view_context = view_context
    @sort_presenter = sort_presenter
    @show_top_result = show_top_result
    @metadata_presenter_class = metadata_presenter_class
  end

  def to_hash
    @to_hash ||= begin
      to_hash_data
    end
  end

  def to_hash_data
    {
      total: "#{number_with_delimiter(total)} #{pluralised_document_noun}",
      any_filters_applied: any_filters_applied?,
      next_and_prev_links: next_and_prev_links,
      facet_tags: facet_tags_markup,
      search_results: search_results_markup,
      sort_options_markup: sort_options_markup,
    }.merge(legacy_attributes)
  end

  # Provided for backwards compatibility
  def legacy_attributes
    {
      pluralised_document_noun: pluralised_document_noun,
      sort_options: sort_options_content,
    }.merge(facet_tags_content).merge(search_results_content)
  end

  def search_results_content
    {
      documents: documents,
      zero_results: total.zero?,
      page_count: documents.count,
      finder_name: finder.name
    }
  end

  def facet_tags_content
    {
      applied_filters: selected_filter_descriptions,
      screen_reader_filter_description: ScreenReaderFilterDescriptionPresenter.new(filters, sort_option).present
    }
  end

  def sort_options_content
    sort_presenter.to_hash
  end

  def any_filters_applied?
    selected_filters.length.positive? || keywords.present?
  end

  def selected_filter_descriptions
    selected_filters.map { |filter|
      FacetTagPresenter.new(filter.sentence_fragment, filter.hide_facet_tag?).present
    }.reject(&:empty?)
  end

  def documents
    @documents ||= begin
      results.each_with_index.map do |result, index|
        metadata = metadata_presenter_class.new(result.metadata).present
        doc = SearchResultPresenter.new(result, metadata).to_hash
        if  index === 0 && highlight_top_result?
          doc[:top_result] = true
          doc[:summary] = result.truncated_description
        end
        {
          document: doc,
          document_index: index + 1
        }
      end
    end
  end

  def user_supplied_date(date_facet_key, date_facet_from_to)
    @filter_params.fetch(date_facet_key, {}).fetch(date_facet_from_to, nil)
  end

  def user_supplied_keywords
    @filter_params.fetch('keywords', '')
  end

  def has_email_signup_link?
    signup_links.any?
  end

  def signup_links
    @signup_links ||= fetch_signup_links
  end

  def next_and_prev_links
    return unless finder.pagination

    current_page = finder.pagination['current_page']
    previous_page = current_page - 1 if current_page > 1
    next_page = current_page + 1 if current_page < finder.pagination['total_pages']
    pages = {}

    pages[:previous_page] = build_page_link("Previous page", previous_page) if previous_page
    pages[:next_page] = build_page_link("Next page", next_page) if next_page

    (view_context.render(formats: %w[html], partial: 'govuk_publishing_components/components/previous_and_next_navigation', locals: pages) || "").squish.html_safe
  end

private

  attr_reader :view_context, :metadata_presenter_class, :sort_presenter

  def search_results_markup
    ApplicationController.render(partial: "finders/search_results", locals: search_results_content).squish
  end

  def facet_tags_markup
    ApplicationController.render(partial: "finders/facet_tags", locals: facet_tags_content).squish
  end

  def sort_options_markup
    ApplicationController.render(partial: "finders/sort_options", locals: sort_options_content).squish
  end

  def highlight_top_result?
    @show_top_result &&
      finder.eu_exit_finder? &&
      results.length >= 2 &&
      sort_option.dig('key').eql?("-relevance") &&
      best_bet?
  end

  def best_bet?
    # We found the average score on the top 500 searches and found that 7 was the most suitable number
    if results[0].es_score && results[1].es_score
      (results[0].es_score / results[1].es_score) > 7
    end
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
    sort_presenter.selected_option || {}
  end

  def fetch_signup_links
    links = {}
    links[:email_signup_link] = email_signup_link if email_signup_link.present?
    links[:feed_link] = feed_link if feed_link.present?
    if email_signup_link.present? || feed_link.present?
      links[:hide_heading] = true
      links[:small_form] = true
    end
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
