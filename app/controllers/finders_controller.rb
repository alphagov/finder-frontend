require 'gds_api/helpers'

class FindersController < ApplicationController
  include GdsApi::Helpers

  def show
    @results = ResultSetPresenter.new(finder, view_context)

    respond_to do |format|
      format.html do
        @navigation_helpers = GovukNavigationHelpers::NavigationHelper.new(raw_finder)
      end
      format.json do
        render json: @results
      end
      format.atom do
        if finder.atom_feed_enabled?
          @feed = AtomPresenter.new(finder)
        else
          render text: 'Not found', status: 404
        end
      end
    end
  end

private
  def finder
    @finder ||= FinderPresenter.new(
      raw_finder,
      filter_params,
    )
  end
  helper_method :finder

  def raw_finder
    FinderApi.new(finder_base_path, filter_params).content_item_with_search_results
  end

  def filter_params
    # TODO Use a whitelist based on the facets in the schema
    permitted_params = params.except(
      :controller,
      :action,
      :slug,
      :format,
    )

    ParamsCleaner.new(permitted_params).cleaned
  end
end
