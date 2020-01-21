class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create
  before_action :signup_presenter
  helper_method :subscriber_list_params

  def create
    validate_choices!
    redirect_to email_alert_signup_api.signup_url
  rescue MissingFiltersError
    render_error "Please choose an email alert"
  rescue UnprocessableFilterAlertParamsError
    render_error "There was a problem with your chosen filters. Please try again."
  rescue EmailAlertSignupAPI::UnprocessableSubscriberListError
    render_error("An error occurred. Please check your filters and try again.")
  end

private

  class MissingFiltersError < StandardError; end
  class UnprocessableFilterAlertParamsError < StandardError; end

  def render_error(error_message)
    @error_message = error_message
    render action: :new
  end

  def content
    @content ||= ContentItem.from_content_store(request.path).as_hash
  end

  def signup_presenter
    @signup_presenter ||= SignupPresenter.new(content, params)
  end

  def subscriber_list_params
    SubscriberListParamsPresenter.new(content, filter_params).subscriber_list_params
  end

  def email_alert_filter_params
    @email_alert_filter_params ||= ParameterParser::EmailAlertParameterParser.new(content, filter_params, params)
  end

  def validate_choices!
    raise UnprocessableFilterAlertParamsError unless email_alert_filter_params.valid?
    raise MissingFiltersError unless email_alert_filter_params.required_facets_selected?
  end

  def applied_filters
    @applied_filters ||= email_alert_filter_params.applied_filters
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      applied_filters: applied_filters,
      default_filters: content["details"].fetch("filter", {}),
      facets: signup_presenter.choices,
      subscriber_list_title: subscriber_list_title,
      email_filter_by: signup_presenter.email_filter_by,
    )
  end

  def subscriber_list_title
    title_builder = signup_presenter.email_filter_by == "facet_values" ? EmailAlertListTitleBuilder : EmailAlertTitleBuilder
    title_builder.call(
      filter: applied_filters,
      subscription_list_title_prefix: content.dig("details", "subscription_list_title_prefix"),
      facets: signup_presenter.choices,
    )
  end
end
