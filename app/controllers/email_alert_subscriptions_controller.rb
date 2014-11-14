require 'email_alert_signup_api'
require 'gds_api/helpers'

class EmailAlertSubscriptionsController < ApplicationController
  include GdsApi::Helpers
  protect_from_forgery except: :create

  def new
    content = content_store.content_item(request.path)
    if content
      @signup = SignupPresenter.new(content)
    else
      error_not_found
    end
  end

  def create
    redirect_to email_alert_signup_api.signup_url
  end

private
  def finder_slug
    params[:slug]
  end

  def finder
    Finder.get(finder_slug)
  end

  def finder_format
    finder.document_type
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      email_alert_api: email_alert_api,
      attributes: email_signup_attributes,
    )
  end

  def email_signup_attributes
    {
      "format" => [finder_format],
    }.merge(choices)
  end

  def choices
    return {} unless params.has_key?(:choices)

    tag_key = params[:choices].keys.first
    {tag_key => params[:choices][tag_key].keys}
  end

  def error_not_found
    render status: :not_found, text: "404 error not found"
  end

end
