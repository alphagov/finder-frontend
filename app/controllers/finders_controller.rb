class FindersController < ApplicationController
  def show
  end

private
  def finder
    @finder ||= Finder.get(finder_slug).tap { |finder|
      finder.facets.values = facet_params
      finder.keywords = keywords unless keywords.blank?
    }
  end
  helper_method :finder

  def finder_slug
    params[:slug]
  end

  def facet_params
    params
  end

  def keywords
    params[:keywords]
  end
end
