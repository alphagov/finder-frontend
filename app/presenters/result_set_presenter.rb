class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :pluralised_document_noun, :debug_score

  delegate :atom_url, to: :finder_presenter

  def initialize(finder_presenter, filter_params, sort_presenter, metadata_presenter_class, show_top_result = false, debug_score = false)
    @finder_presenter = finder_presenter
    @documents = finder_presenter.results.documents
    @total = finder_presenter.results.total
    @pluralised_document_noun = finder_presenter.document_noun.pluralize(total)
    @filter_params = filter_params
    @sort_presenter = sort_presenter
    @show_top_result = show_top_result
    @metadata_presenter_class = metadata_presenter_class
    @debug_score = debug_score
  end

  def displayed_total
    "#{number_with_delimiter(total)} #{pluralised_document_noun}"
  end

  def search_results_content
    {
      document_list_component_data: document_list_component_data,
      zero_results: total.zero?,
      page_count: document_list_component_data.count,
      finder_name: finder_presenter.name,
      debug_score: debug_score
    }
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

  def highlight_top_result?
    @show_top_result &&
      finder_presenter.eu_exit_finder? &&
      documents.length >= 2 &&
      sort_option.dig('key').eql?("-relevance") &&
      best_bet?
  end

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total, :finder_presenter, :documents

  def document_list_component_data(documents_to_convert: documents)
    documents_to_convert.map do |document|
      SearchResultPresenter.new(document: document, metadata_presenter_class: metadata_presenter_class, doc_count: documents.count, finder_name: finder_presenter.name, debug_score: debug_score, highlight: highlight(document.index)).document_list_component_data
    end
  end

  def highlight(index)
    index === 1 && highlight_top_result?
  end

  def best_bet?
    # We found the average score on the top 500 searches and found that 7 was the most suitable number
    if documents[0].es_score && documents[1].es_score
      (documents[0].es_score / documents[1].es_score) > 7
    end
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
    return '' unless finder_presenter.respond_to?(:email_alert_signup_url)

    finder_presenter.email_alert_signup_url
  end

  def feed_link
    return '' unless finder_presenter.respond_to?(:atom_url)

    finder_presenter.atom_url
  end
end
