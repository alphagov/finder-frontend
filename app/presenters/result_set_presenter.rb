class ResultSetPresenter
  include ERB::Util
  include ActionView::Helpers::NumberHelper

  attr_reader :results, :pluralised_document_noun, :debug_score

  delegate :atom_url, to: :finder_presenter

  def initialize(finder_presenter, filter_params, sort_presenter, metadata_presenter_class, show_top_result = false, debug_score = false)
    @finder_presenter = finder_presenter
    @results = finder_presenter.results.documents
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
      documents: documents,
      zero_results: total.zero?,
      page_count: documents.count,
      finder_name: finder_presenter.name,
      debug_score: debug_score
    }
  end

  def documents
    @documents ||= begin
      results.each_with_index.map do |result, index|
        metadata = metadata_presenter_class.new(result.metadata).present
        doc = SearchResultPresenter.new(result, metadata).to_hash
        structure_document_content(doc, result, index, results.count)
      end
    end
  end

  def structure_document_content(doc, result, index, count)
    component_metadata = {}

    if index === 0 && highlight_top_result?
      doc[:top_result] = true
      doc[:summary] = result.truncated_description
      highlight_text = "Most relevant result"
    end

    # The logic for showing or not showing metadata used to be in the view
    # moving it here and simply not including it seemed logical but
    # the grouped presenter relies on the metadata to do something
    # so we need a way of having the metadata available for that but not then
    # passing it to the component if we're not supposed to

    if doc[:show_metadata]
      doc[:metadata].each do |meta|
        label = meta[:hide_label] ? "<span class='govuk-visually-hidden'>#{meta[:label]}:</span>" : "#{meta[:label]}:"

        if meta[:is_date]
          value = "<time datetime='#{meta[:machine_date]}'>#{meta[:human_date]}</time>"
        else
          value = meta[:value]
        end

        component_metadata[meta[:label]] = "#{label} #{value}".html_safe
      end
    end

    published_text = "<span class='published-by'>First published during the #{doc[:government_name]}</span>" if doc[:is_historic]
    debug_text = "<span class='debug-results debug-results--link'>#{doc[:link]}</span>"\
                 "<span class='debug-results debug-results--meta'>Score: #{doc[:es_score] || "no score (sort by relevance)"}</span>"\
                 "<span class='debug-results debug-results--meta'>Format: #{doc[:format]}</span>" if debug_score
    subtext = "#{published_text}#{debug_text}".html_safe if published_text || debug_text

    {
      link: {
        text: doc[:title],
        path: doc[:link],
        description: doc[:summary],
        data_attributes: {
          track_category: "navFinderLinkClicked",
          track_action: "#{finder.name}.#{index + 1}",
          track_label: doc[:link],
          track_options: {
            dimension28: count,
            dimension29: doc[:title]
          }
        }
      },
      metadata: component_metadata,
      metadata_raw: doc[:metadata],
      subtext: subtext,
      highlight: doc[:top_result],
      highlight_text: highlight_text
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

private

  attr_reader :metadata_presenter_class, :sort_presenter, :total, :finder_presenter

  def highlight_top_result?
    @show_top_result &&
      finder_presenter.eu_exit_finder? &&
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
    return '' unless finder_presenter.respond_to?(:email_alert_signup_url)

    finder_presenter.email_alert_signup_url
  end

  def feed_link
    return '' unless finder_presenter.respond_to?(:atom_url)

    finder_presenter.atom_url
  end
end
