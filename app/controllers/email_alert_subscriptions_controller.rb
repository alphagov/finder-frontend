require 'email_alert_signup_api'

class EmailAlertSubscriptionsController < ApplicationController
  layout "finder_layout"
  protect_from_forgery except: :create
  before_action :signup_presenter
  helper_method :hidden_params

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
    @content ||= fetch_content
  end

  def fetch_content
    if development_env_finder_json
      JSON.parse(File.read("features/fixtures/news_and_communications_signup_content_item.json"))
    else
      Services.content_store.content_item(request.path)
    end
  end

  def signup_presenter
    @signup_presenter ||= SignupPresenter.new(content, params)
  end

  def hidden_params
    SignupUrlHiddenParamsPresenter.new(content, view_context).hidden_params
  end

  def valid_choices?
    !signup_presenter.choices? || at_least_one_filter_chosen?
  end

  def at_least_one_filter_chosen?
    chosen_options.any?(&:present?)
  end

  def chosen_options
    options = params.permit("filter" => {})['filter'].to_h
    return options unless params[:hidden_params].present?

    options.merge(params[:hidden_params].to_unsafe_hash)
  end

  def finder
    if development_env_finder_json
      FinderPresenter.new(JSON.parse(File.read("features/fixtures/news_and_communications.json")))
    else
      FinderPresenter.new(Services.content_store.content_item(finder_base_path))
    end
  end

  def development_env_finder_json
    return news_and_communications_json if is_news_and_communications?

    ENV["DEVELOPMENT_FINDER_JSON"]
  end

  def news_and_communications_json
    # Hard coding this in during development
    "features/fixtures/news_and_communications.json"
  end

  def is_news_and_communications?
    finder_base_path == "/news-and-communications"
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
