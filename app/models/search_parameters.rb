class SearchParameters
  def initialize(params)
    @params = enforce_bounds(search_params(params))
  end

  def search_term
    full_term = params[:q]&.strip&.gsub(/\s{2,}/, " ")
    unless full_term.nil?
      full_term[0, Search::QueryBuilder::MAX_QUERY_LENGTH]
    end
  end

  def no_search?
    search_term.blank?
  end

private

  attr_reader :params

  DEFAULT_RESULTS_PER_PAGE = 20
  MAX_RESULTS_PER_PAGE = 100
  ALLOWED_FACET_FIELDS = %w{organisations manual}.freeze

  def search_params(params)
    params.
      permit(:q, :start, :count,
             :debug_score, :debug, :format,
             # allow facets as array values like:
             #     filter_foo[]=bar&filter_foo[]=baz
             Hash[ALLOWED_FACET_FIELDS.map { |facet| [:"filter_#{facet}", []] }],
             # and allow facets as single string values like
             #     filter_foo=bar
             *ALLOWED_FACET_FIELDS.map { |facet| :"filter_#{facet}" }).
      to_h
  end

  def enforce_bounds(params)
    params.merge(
      start: check_start(params),
      count: check_count(params),
    )
  end

  def check_start(params)
    start = (params[:start] || 0).to_i
    if start.negative?
      0
    else
      start
    end
  end

  def check_count(params)
    count = (params[:count] || 0).to_i
    if count <= 0
      DEFAULT_RESULTS_PER_PAGE
    elsif count > MAX_RESULTS_PER_PAGE
      MAX_RESULTS_PER_PAGE
    else
      count
    end
  end
end
