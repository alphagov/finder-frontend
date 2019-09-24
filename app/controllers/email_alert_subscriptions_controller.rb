class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create
  before_action :signup_presenter
  helper_method :subscriber_list_params

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
    @content ||= fetch_content_item(request.path)
  end

  def finder_content_item
    @finder_content_item ||= fetch_content_item(finder_base_path)
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
    applied_filters.any?(&:present?)
  end

  def has_default_filters?
    default_filters.present? && default_filters.any?
  end

  def applied_filters
    params
      .permit("filter" => {})
      .dig("filter")
      .to_h
      .merge(
        filter_params.fetch("subscriber_list_params", {}),
      )
  end

  def fetch_content_item(content_item_path)
    ContentItem.from_content_store(content_item_path).as_hash
  end

  def email_alert_signup_api
    EmailAlertSignupAPI.new(
      applied_filters: applied_filters,
      default_filters: default_filters,
      facets: signup_presenter.choices,
      finder_format: finder_format,
      subscriber_list_title: subscriber_list_title,
      default_frequency: signup_presenter.default_frequency,
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

  def default_filters
    content["details"].fetch("filter", {})
  end

  def finder_format
    finder_content_item.dig("details", "filter", "document_type")
  end
end
