class SearchController < ApplicationController
  layout "search_layout"
  before_action :set_expiry
  before_action :remove_search_box

  def index
    search_params = SearchParameters.new(params)

    @content_item = content_store.content_item("/search").to_hash
    if search_params.no_search? && params[:format] != "json"
      render(action: 'no_search_term') && return
    end

    search_response = SearchAPI.new(search_params).search

    @search_term = search_params.search_term

    @results = if search_response["scope"].present?
                 ScopedSearchResultsPresenter.new(search_response, search_params, view_context)
               else
                 SearchResultsPresenter.new(search_response, search_params, view_context)
               end

    @facets = search_response["facets"]
    @spelling_suggestion = @results.spelling_suggestion

    fill_in_slimmer_headers(@results.result_count)

    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

protected

  def set_expiry(duration = 30.minutes)
    unless Rails.env.development?
      expires_in(duration, public: true)
    end
  end

  def remove_search_box
    set_slimmer_headers(remove_search: true)
  end

  def fill_in_slimmer_headers(result_count)
    set_slimmer_headers(
      result_count: result_count,
      section:      "search",
    )
  end
end
