class FindersController < ApplicationController
  def show
  end

private
  def finder
    @finder ||= Finder.get_with_facet_values(finder_slug, facet_params)
  end
  helper_method :finder

  def finder_slug
    params[:slug]
  end

  def facet_params
    params
  end
end
