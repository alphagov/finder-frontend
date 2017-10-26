require 'gds_api/helpers'

class SearchController < ApplicationController
  include GdsApi::Helpers
  before_action :set_expiry
  before_action :remove_search_box

  helper_method :search_ab_test_variant
  after_action :set_search_ab_test_response_header

  rescue_from GdsApi::BaseError, with: :error_503
  layout 'search-application'

  SEARCH_AB_TEST_DIMENSION = 42

  def index
    search_params = SearchParameters.new(params)

    @content_item = content_store.content_item("/search").to_hash
    @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(@content_item)
    # Remove the organisations from the content item - this will prevent the
    # govuk:analytics:organisations meta tag from being generated until there is
    # a better way of doing this. This is so we don't add the tag to pages that
    # didn't have it before, thereby swamping analytics.
    if @content_item["links"]
      @content_item["links"].delete("organisations")
    end

    if search_params.no_search? && params[:format] != "json"
      render(action: 'no_search_term') && return
    end

    variant = search_ab_test_variant.variant_name
    search_response = SearchAPI.new(search_params, format_weighting: variant).search

    @search_term = search_params.search_term

    @results = if search_response["scope"].present?
                 ScopedSearchResultsPresenter.new(search_response, search_params, view_context)
               else
                 SearchResultsPresenter.new(search_response, search_params, view_context)
               end

    @facets = search_response["facets"]
    @spelling_suggestion = @results.spelling_suggestion

    fill_in_slimmer_headers(@results.result_count)
    response.headers['foo'] = 'bar'
    respond_to do |format|
      format.html
      format.json { render json: @results }
    end
  end

  def search_ab_test
    GovukAbTesting::AbTest.new(
      "FormatWeighting",
      dimension: SEARCH_AB_TEST_DIMENSION
    )
  end

  def search_ab_test_variant
    @_search_ab_test_variant ||=
      search_ab_test.requested_variant(request.headers)
  end

  def set_search_ab_test_response_header
    search_ab_test_variant.configure_response(response)
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
