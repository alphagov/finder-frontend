class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::SharedTemplates
  before_filter :set_slimmer_headers, :set_robots_headers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application

private
  def set_slimmer_headers
    response.headers[Slimmer::Headers::TEMPLATE_HEADER] = "header_footer_only"
  end

  def set_robots_headers
    if finders_excluded_from_robots.include?(finder_slug)
      response.headers["X-Robots-Tag"] = "none"
    end
  end

  def finders_excluded_from_robots
    [
      'aaib-reports',
      'drug-safety-update',
      'drug-device-alerts',
      'maib-reports',
    ]
  end

  def finder_slug
    raise NotImplementedError
  end

end
