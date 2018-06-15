class SearchResultsPresenter
  include ActionView::Helpers::TextHelper
  include ActionView::Helpers::NumberHelper
  include Rails.application.routes.url_helpers

  FACET_TITLES = {
    "organisations" => "Organisations",
  }.freeze

  def initialize(search_response, search_parameters, view_context)
    @search_response = search_response
    @search_parameters = search_parameters
    @view_context = view_context
  end

  def to_hash
    {
      query: search_parameters.search_term,
      result_count: result_count,
      result_count_string: result_count_string(result_count),
      results_any?: results.any?,
      results: results,
      filter_fields: filter_fields,
      debug_score: search_parameters.debug_score,
      first_result_number: (search_parameters.start + 1),
      next_and_prev_links: next_and_prev_links
    }
  end

  def filter_fields
    search_response["facets"].map do |field, value|
      facet_params = search_parameters.filter(field)
      facet = SearchFacetPresenter.new(value, facet_params).to_hash

      {
        field: field,
        field_title: FACET_TITLES.fetch(field, field),
        options: facet,
        show_organisations_filter: show_organisations_filter?(facet),
      }
    end
  end

  SpellingSuggestion = Struct.new(:query, :link)

  def spelling_suggestion
    queries = search_response["suggested_queries"]
    if queries.present?
      SpellingSuggestion.new(
        queries.first,
        search_parameters.build_link(
          q: queries.first,

          # Record original query, for analytics
          o: search_parameters.search_term,
        ),
      )
    end
  end

  def result_count
    search_response["total"].to_i
  end

  def result_count_string(count)
    pluralize(number_with_delimiter(count), "result")
  end

  def results
    search_response["results"].map { |result| build_result(result).to_hash }
  end

  def build_result(result)
    if result["document_type"] == "group"
      GroupResult.new(search_parameters, result)
    elsif result["document_type"] && result["document_type"] != "edition"
      NonEditionResult.new(search_parameters, result)
    elsif result["index"] == "government"
      GovernmentResult.new(search_parameters, result)
    else
      SearchResult.new(search_parameters, result)
    end
  end

  def show_organisations_filter?(facet)
    search_parameters.show_organisations_filter? || facet[:any?]
  end

  def next_and_prev_links
    pages = {}

    if search_parameters.start.positive?
      pages[:previous_page] = build_page_link("Previous page", previous_page_number, previous_page_start)
    end

    if (search_parameters.start + search_parameters.count) < result_count
      pages[:next_page] = build_page_link("Next page", next_page_number, next_page_start)
    end

    view_context.render(formats: ["html"], partial: 'govuk_publishing_components/components/previous_and_next_navigation', locals: pages) if pages.any?
  end

private

  attr_reader :search_parameters, :search_response, :view_context

  def build_page_link(page_label, page, page_start)
    {
      url: search_parameters.build_link(start: page_start),
      title: page_label,
      label: "#{page} of #{total_pages}",
    }
  end

  def next_page_start
    search_parameters.start + search_parameters.count
  end

  def previous_page_start
    start_at = search_parameters.start - search_parameters.count
    start_at.negative? ? 0 : start_at
  end

  def total_pages
    # when count is zero, there would only ever be one page of results
    return 1 if search_parameters.count.zero?

    (result_count.to_f / search_parameters.count.to_f).ceil
  end

  def current_page_number
    # if start is zero, then we must be on the first page
    return 1 if search_parameters.start.zero?

    # eg. when start = 50 and count = 10:
    #          (50 / 10) + 1 = page 6
    (search_parameters.start.to_f / search_parameters.count.to_f).ceil + 1
  end

  def next_page_number
    current_page_number + 1
  end

  def previous_page_number
    current_page_number - 1
  end
end
