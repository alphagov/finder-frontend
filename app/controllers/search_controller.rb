class SearchController < ApplicationController
  layout "search_layout"
  before_action :set_expiry
  before_action :remove_search_box

  def index
    search_params = SearchParameters.new(params)

    @content_item = Services.cached_content_item("/search")

    # Redirect all requests to all content finder, where either search params have been supplied or the user is
    # requesting the JSON endpoint.
    if !search_params.no_search? || params[:format] == "json"
      redirect_to_all_content_finder(search_params) && return
    end

    render(action: "no_search_term") && return
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

  def redirect_to_all_content_finder(search_params)
    all_content_params = {
      keywords: search_params.search_term,
      organisations: params["filter_organisations"],
      manual: params["filter_manual"],
      format: params["format"],
      order: "relevance",
    }.compact

    redirect_to(finder_path("search/all", params: all_content_params), status: :moved_permanently)
  end
end
