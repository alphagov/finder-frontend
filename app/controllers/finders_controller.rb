require 'gds_api/helpers'

class FindersController < ApplicationController
  include GdsApi::Helpers

  def show
    @results = ResultSetPresenter.new(finder)

    respond_to do |format|
      format.html
      format.json do
        render json: @results
      end
      if finder.atom_feed_enabled?
        format.atom do
          @feed = AtomPresenter.new(finder)
        end
      end
    end
  end

private
  def finder
    @finder ||= FinderPresenter.new(
      raw_finder,
      facet_params,
    )
  end
  helper_method :finder

  def raw_finder
    finder_api.fetch(
      finder_base_path,
      facet_params,
    )
  end

  def finder_api
    FinderFrontend.finder_api
  end

  def facet_params
    # TODO Use a whitelist based on the facets in the schema
    params.except(
      :controller,
      :action,
      :slug,
      :format,
    )
  end
end
