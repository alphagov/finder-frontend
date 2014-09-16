require 'email_alert_signup_api'

class EmailAlertSubscriptionsController < ApplicationController

  def new
  end

  def create
    signup_url = email_alert_signup_api.signup_url
    redirect_to signup_url
  end

private
  def finder_slug
    params[:slug]
  end

  def finder
    Finder.get(finder_slug)
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      delivery_api: delivery_api,
      alert_identifier: finder_url_for_alert_type,
      alert_name: finder.name
    )
  end

  def delivery_api
    @delivery_api ||= GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
  end

  def finder_url_for_alert_type
    @finder_url_for_alert_type ||= "#{Plek.current.find('finder-frontend')}/#{finder_slug}.atom"
  end

end
