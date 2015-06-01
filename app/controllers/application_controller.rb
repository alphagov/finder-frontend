class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::SharedTemplates
  before_filter :set_slimmer_headers

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application
  rescue_from GdsApi::HTTPNotFound, with: :error_not_found

private
  def set_slimmer_headers
    response.headers[Slimmer::Headers::TEMPLATE_HEADER] = "header_footer_only"
  end

  def finder_base_path
    "/#{finder_slug}"
  end

  def finder_slug
    params[:slug]
  end

  def error_not_found
    render status: :not_found, text: "404 error not found"
  end
end
