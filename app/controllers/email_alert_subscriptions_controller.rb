require 'email_alert_signup_api'
require 'gds_api/helpers'

class EmailAlertSubscriptionsController < ApplicationController
  include GdsApi::Helpers
  protect_from_forgery except: :create

  def new
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

  def content
    @content ||= content_store.content_item(request.path)
  end

  def finder_slug
    params[:slug]
  end

  def finder
    FinderPresenter.new(content_store.content_item("/#{finder_slug}"))
  end

  def finder_format
    finder.document_type
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      email_alert_api: email_alert_api,
      attributes: email_signup_attributes,
      subscription_list_title_prefix: content.details.subscription_list_title_prefix,
      available_choices: content.details.email_signup_choice,
    )
  end

  def email_signup_attributes
    {
      "format" => [finder_format],
      "filter" => params["filter"],
    }
  end

  def error_not_found
    render status: :not_found, text: "404 error not found"
  end

end

