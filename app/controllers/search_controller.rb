require 'gds_api/helpers'

class SearchController < ApplicationController
  include GdsApi::Helpers
  # before_filter :set_expiry
  before_filter :remove_search_box

  rescue_from GdsApi::BaseError, with: :error_503
  layout 'without-id-application'

  def index
    search_params = SearchParameters.new(params)

    @content_item = content_store.content_item("/search").to_hash
    # Remove the organisations from the content item - this will prevent the
    # govuk:analytics:organisations meta tag from being generated until there is
    # a better way of doing this. This is so we don't add the tag to pages that
    # didn't have it before, thereby swamping analytics.
    if @content_item["links"]
      @content_item["links"].delete("organisations")
    end

    if search_params.no_search? && params[:format] != "json"
      render action: 'no_search_term' and return
    end
    search_response = SearchAPI.new(search_params).search

    @search_term = search_params.search_term

    if (search_response["scope"].present?)
      @results = ScopedSearchResultsPresenter.new(search_response, search_params)
    else
      @results = SearchResultsPresenter.new(search_response, search_params)
    end

    @facets = search_response["facets"]
    @spelling_suggestion = @results.spelling_suggestion

    fill_in_slimmer_headers(@results.result_count)

    respond_to do |format|
      format.html { render locals: { full_width: true } }
      format.json { render json: @results }
    end
  end

protected

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
