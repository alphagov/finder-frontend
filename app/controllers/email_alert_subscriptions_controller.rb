require 'email_alert_signup_api'
require 'gds_api/helpers'
require 'artefact_api'

class EmailAlertSubscriptionsController < ApplicationController
  include GdsApi::Helpers
  protect_from_forgery except: :create

  def new
    @signup = SignupPresenter.new(signup_page)
  end

  def create
    signup_url = email_alert_signup_api.signup_url
    redirect_to signup_url
  end

private
  def finder_slug
    params[:slug]
  end

  def artefact_slug
    # So using request.env["PATH_INFO"] has a leading slash which would need
    # removing before asking the content api for the artefact. I don't like this
    # either but I prefer it to string manip.
    "#{finder_slug}/email-signup"
  end

  def signup_page
    EmailSignupPage.new(
      slug: finder_slug,
      artefact: artefact_api.get(artefact_slug),
      schema_facets: schema_hash.fetch("facets"),
    )
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      delivery_api: delivery_api,
      alert_identifier: finder_url_for_alert_type,
      alert_name: signup_page.title
    )
  end

  def artefact_api
    ArtefactAPI.new(
      content_api: content_api,
    )
  end

  def delivery_api
    @delivery_api ||= GdsApi::GovUkDelivery.new(Plek.current.find('govuk-delivery'))
  end

  def finder_url_for_alert_type
    parameter_string = URI.escape(facet_params.collect{ |k,v| "#{k}=#{v}"}.join('&') )
    @finder_url_for_alert_type ||= "#{Plek.current.find('finder-frontend')}/#{finder_slug}.atom?#{parameter_string}"
  end

  def schema_hash
    FinderFrontend.get_schema(finder_slug).send(:schema_hash)
  end

  def facet_params
    # TODO Use a whitelist based on the facets in the schema
    params.except(
      "controller",
      "action",
      "slug",
      "format",
      "utf8",
      "authenticity_token",
      "commit",
    )
  end
end
