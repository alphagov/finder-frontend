class FindersController < ApplicationController
  def show
  end

private
  def finder
    @finder ||= Finder.build(api: finder_api, facet_values: facet_params)
  end
  helper_method :finder

  def finder_api
    FinderApi.new(finder_slug)
  end

  def finder_slug
    params[:slug]
  end

  def facet_params
    params
  end
end
