class FindersController < ApplicationController

  before_filter :set_robots_headers

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

  def set_robots_headers
    if finders_excluded_from_robots.include?(finder_slug)
      response.headers["X-Robots-Tag"] = "none"
    end
  end

  def finders_excluded_from_robots
    [
      'aaib-reports'
    ]
  end
end
