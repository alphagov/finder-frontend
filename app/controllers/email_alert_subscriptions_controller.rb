require 'email_alert_signup_api'

class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create
  before_action :signup_presenter
  helper_method :subscriber_list_params

  def create
    error_message = email_alert_signup_api.validate!

    if error_message.nil? && valid_choices?
      redirect_to email_alert_signup_api.signup_url
    else
      @error_message = error_message || "Please choose an email alert"
      render action: :new
    end
  end

private

  def content
    @content ||= fetch_content_item(request.path)
  end

  def signup_presenter
    @signup_presenter ||= SignupPresenter.new(content, params)
  end

  def subscriber_list_params
    SubscriberListParamsPresenter.new(content, filter_params).subscriber_list_params
  end

  def valid_choices?
    !signup_presenter.choices? || at_least_one_filter_chosen? || has_default_filters?
  end

  def at_least_one_filter_chosen?
    chosen_options.any?(&:present?)
  end

  def has_default_filters?
    default_filters.present? && default_filters.any? || default_rejects.present? && default_rejects.any?
  end

  def chosen_options
    params
      .permit("filter" => {})['filter']
      .to_h
      .merge(
        filter_params.fetch('subscriber_list_params', {})
      )
  end

  def fetch_content_item(content_item_path)
    FinderApi.new(content_item_path, {}).content_item
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      email_alert_api: Services.email_alert_api,
      attributes: email_signup_attributes,
      default_attributes: { filter: default_filters, reject: default_rejects },
      subscription_list_title_prefix: content['details']['subscription_list_title_prefix'],
      available_choices: signup_presenter.choices,
    )
  end

  def finder
    @finder ||= FinderPresenter.new(fetch_content_item(finder_base_path))
  end

  def finder_format
    return nil unless finder.filter

    finder.filter['document_type']
  end

  def email_signup_attributes
    { "filter" => chosen_options }.tap do |hash|
      hash["format"] = [finder_format] if finder_format
    end
  end

  def default_filters
    content['details'].fetch('filter', {})
  end

  def default_rejects
    content['details'].fetch('reject', {})
  end
end
