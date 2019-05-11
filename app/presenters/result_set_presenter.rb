class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :finder, :document_noun, :results, :total

  delegate :document_noun,
           :filters,
           :keywords,
           :atom_url,
           to: :finder

  def initialize(finder, filter_params, sort_presenter, next_and_prev_links, show_top_result = false)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @filter_params = filter_params
    @sort_presenter = sort_presenter
    @show_top_result = show_top_result
    @next_and_prev_links = next_and_prev_links
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
      screen_reader_filter_description: ScreenReaderFilterDescriptionPresenter.new(filters, sort_option).present,
      sort_options: sort_presenter.to_hash,
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
      FacetTagPresenter.new(filter.sentence_fragment, filter.hide_facet_tag?).present
    }.reject(&:empty?)
  end

  def documents
    results.each_with_index.map do |result, index|
      doc = SearchResultPresenter.new(result).to_hash
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

private

  attr_reader :sort_presenter, :next_and_prev_links

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
