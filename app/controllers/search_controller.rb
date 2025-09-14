class SearchController < ApplicationController
  layout "search_layout"

  def index
    search_params = SearchParameters.new(params)

    @content_item = ContentItem.from_content_store("/search")
    set_expiry(@content_item)

    # Redirect all requests to all content finder, where either search params have been supplied or the user is
    # requesting the JSON endpoint.
    if !search_params.no_search? || params[:format] == "json"
      redirect_to_all_content_finder(search_params) && return
    end

    render(action: "no_search_term") && return
  end

protected

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
