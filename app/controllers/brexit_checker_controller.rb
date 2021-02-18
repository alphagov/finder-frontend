class BrexitCheckerController < ApplicationController
  include AccountBrexitCheckerConcern
  include BrexitCheckerHelper

  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action :enable_caching, only: %i[show email_signup confirm_email_signup]
  before_action :enable_caching_unless_accounts, only: %i[results]

  helper_method :subscriber_list_slug

  def show
    all_questions = BrexitChecker::Question.load_all

    @question_index = next_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      previous_question_index: page,
    )

    @current_question = all_questions[@question_index] if @question_index.present?

    @previous_page = previous_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      current_question_index: page,
    )

    redirect_to transition_checker_results_path(c: criteria_keys) if @current_question.nil?
  end

  def results
    @presenter = result_presenter
  end

  def email_signup; end

  def confirm_email_signup
    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

  def save_results; end

  def save_results_sign_up
    jwt = account_signup_jwt(criteria_keys, subscriber_list_slug)

    tokens = Rails.cache.fetch("finder-frontend_account_oauth_token") || Services.oidc.tokens!

    response = Services.oidc.submit_jwt(
      jwt: jwt,
      access_token: tokens[:access_token],
      refresh_token: tokens[:refresh_token],
    )

    Rails.cache.write(
      "finder-frontend_account_oauth_token",
      { access_token: response[:access_token], refresh_token: response[:refresh_token] },
      expires_in: 24.hours,
    )

    redirect_to transition_checker_new_session_path(
      redirect_path: transition_checker_save_results_confirm_path(c: criteria_keys),
      state: response[:result],
      _ga: params[:_ga],
    )
  rescue OidcClient::OAuthFailure
    head :internal_server_error
  end

  def save_results_confirm
    redirect_to transition_checker_results_path(c: criteria_keys) and return if criteria_keys == @saved_results

    @has_email_subscription = oauth_fetch_email_subscription_from_account_or_logout
    redirect_to logged_out_pre_update_results_path unless logged_in?
  end

  def save_results_email_signup; end

  def save_results_apply
    if params[:email_decision] == "yes"
      oauth_update_email_subscription_in_account_or_logout subscriber_list_slug
    end

    oauth_update_answers_in_account_or_logout criteria_keys

    if logged_in?
      redirect_to transition_checker_results_path(c: criteria_keys)
    else
      redirect_to logged_out_pre_update_results_path
    end
  end

  def saved_results
    if @saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_results_path(c: @saved_results)
    end
  end

  def edit_saved_results
    if @saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_questions_path(c: @saved_results, page: 0)
    end
  end

private

  def subscriber_list_slug
    @subscriber_list_slug ||= Services.email_alert_api
      .find_or_create_subscriber_list_cached(subscriber_list_options)
      .dig("subscriber_list", "slug")
  end

  def enable_caching
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def enable_caching_unless_accounts
    enable_caching unless accounts_enabled?
  end

  def subscriber_list_options
    path = transition_checker_results_path(c: criteria_keys)

    {
      "title" => "Brexit checker results",
      "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
      "url" => path,
    }
  end

  def criteria_keys
    @criteria_keys ||= begin
                         keys = ParamsCleaner.new(params).fetch(:c, [])
                         BrexitChecker::Criteria::Filter.new.call(keys)
                       end
  end
  helper_method :criteria_keys

  def page
    @page ||= ParamsCleaner.new(params).fetch(:page, "0").to_i
  end

  def result_presenter
    @result_presenter ||= BrexitChecker::Results::ResultPresenter.new(criteria_keys)
  end
end
