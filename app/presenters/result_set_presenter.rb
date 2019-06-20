# typed: true
class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :finder, :results, :pluralised_document_noun, :debug_score

  delegate :atom_url, to: :finder

  def initialize(finder, filter_params, sort_presenter, metadata_presenter_class, show_top_result = false, debug_score = false)
    @finder = finder
    @results = finder.results.documents
    @total = finder.results.total
    @pluralised_document_noun = finder.document_noun.pluralize(total)
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
      documents: documents,
      zero_results: total.zero?,
      page_count: documents.count,
      finder_name: finder.name,
      debug_score: debug_score,
    }
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

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total

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
