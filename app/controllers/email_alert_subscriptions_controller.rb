require 'email_alert_signup_api'

class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create
  before_action :signup_presenter

  def new; end

  def create
    if valid_choices?
      redirect_to email_alert_signup_api.signup_url
    else
      @error_message = "Please choose an email alert"
      render action: :new
    end
  end

private

  def content
    @content ||= Services.content_store.content_item(request.path)
  end

  def signup_presenter
    @signup_presenter ||= SignupPresenter.new(content, params)
  end

  def valid_choices?
    !signup_presenter.choices? || at_least_one_filter_chosen?
  end

  def at_least_one_filter_chosen?
    chosen_options.any?(&:present?)
  end

  def chosen_options
    params.permit("filter" => {})['filter'].to_h
  end

  def finder
    FinderPresenter.new(Services.content_store.content_item(finder_base_path))
  end

  def finder_format
    return nil unless finder.filter

    finder.filter['document_type']
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      email_alert_api: Services.email_alert_api,
      attributes: email_signup_attributes,
      subscription_list_title_prefix: content['details']['subscription_list_title_prefix'],
      available_choices: signup_presenter.choices,
    )
  end

  def email_signup_attributes
    { "filter" => chosen_options }.tap do |hash|
      hash["format"] = [finder_format] if finder_format
    end
  end
end
