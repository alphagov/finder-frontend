class ApplicationController < ActionController::Base
  include Slimmer::Headers
  before_filter :set_slimmer_headers
  before_filter :set_beta_notice

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application


private
  def set_slimmer_headers
    response.headers[Slimmer::Headers::TEMPLATE_HEADER] = "header_footer_only"
  end

  def set_beta_notice
    response.headers[Slimmer::Headers::BETA_HEADER] = "true"
  end
end
