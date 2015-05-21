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
      format.atom do
        @feed = AtomPresenter.new(finder)
      end
    end
  end

private
  def finder
    @finder ||= FinderPresenter.new(
      content_store.content_item!("/#{finder_slug}"),
      facet_params,
    )
  end
  helper_method :finder

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
