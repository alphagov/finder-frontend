class BrexitCheckerController < ApplicationController
  include AccountAbTestable

  include BrexitCheckerHelper

  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action :check_accounts_enabled, only: %i[save_results save_results_confirm save_results_email_signup save_results_apply saved_results edit_saved_results]
  before_action :enable_caching, only: %i[show email_signup confirm_email_signup]
  before_action :enable_caching_unless_accounts, only: %i[results]
  before_action :set_account_session_cookie
  before_action :set_account_variant

  helper_method :subscriber_list_slug, :account_variant

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
    if accounts_enabled?
      results_in_account = results_from_account
      if logged_in?
        now = Time.zone.now.to_i
        @results_differ = criteria_keys != results_in_account.fetch("criteria_keys", [])
        @results_saved = !@results_differ && results_in_account.fetch("timestamp", now) >= now - 10
      end
    end

    @presenter = result_presenter
  end

  def email_signup; end

  def confirm_email_signup
    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

  def save_results
    @account_jwt = account_signup_jwt(criteria_keys, subscriber_list_slug)
  rescue StandardError
    redirect_to transition_checker_email_signup_path(c: criteria_keys)
  end

  def save_results_confirm
    saved_results = results_from_account.fetch("criteria_keys", [])
    redirect_to transition_checker_new_session_path(redirect_path: transition_checker_save_results_confirm_path(c: criteria_keys), _ga: params[:_ga]) and return unless logged_in?

    @old_criteria_keys = saved_results
    redirect_to transition_checker_results_path(c: criteria_keys) and return if criteria_keys == @old_criteria_keys

    @has_email_subscription = update_account_session_cookie_from_oauth_result(
      Services.oidc.has_email_subscription(
        access_token: account_session_cookie_value[:access_token],
        refresh_token: account_session_cookie_value[:refresh_token],
      ),
    )
  end

  def save_results_email_signup; end

  def save_results_apply
    if params[:email_decision] == "yes"
      update_account_session_cookie_from_oauth_result(
        Services.oidc.update_email_subscription(
          slug: subscriber_list_slug,
          access_token: account_session_cookie_value[:access_token],
          refresh_token: account_session_cookie_value[:refresh_token],
        ),
      )
    end
    update_account_session_cookie_from_oauth_result(
      Services.oidc.set_checker_attribute(
        value: { criteria_keys: criteria_keys, timestamp: Time.zone.now.to_i },
        access_token: account_session_cookie_value[:access_token],
        refresh_token: account_session_cookie_value[:refresh_token],
      ),
    )
    redirect_to transition_checker_results_path(c: criteria_keys)
  rescue OidcClient::OAuthFailure => e
    # this means the refresh token has been revoked or the
    # accounts services are down
    logout!
    raise e
  end

  def saved_results
    saved_results = results_from_account.fetch("criteria_keys", [])
    redirect_to transition_checker_new_session_path(redirect_path: transition_checker_saved_results_path, _ga: params[:_ga]) and return unless logged_in?

    if saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_results_path(c: saved_results)
    end
  end

  def edit_saved_results
    saved_results = results_from_account.fetch("criteria_keys", [])
    redirect_to transition_checker_new_session_path(redirect_path: transition_checker_edit_saved_results_path, _ga: params[:_ga]) and return unless logged_in?

    if saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_questions_path(c: saved_results, page: 0)
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

  def set_account_variant
    return unless accounts_enabled?
    return unless show_signed_in_header? || show_signed_out_header?

    account_variant.configure_response(response)

    set_slimmer_headers(
      remove_search: true,
      show_accounts: show_signed_in_header? ? "signed-in" : "signed-out",
    )
  end

  def results_from_account
    return {} unless account_session_cookie_value

    update_account_session_cookie_from_oauth_result(
      Services.oidc.get_checker_attribute(
        access_token: account_session_cookie_value[:access_token],
        refresh_token: account_session_cookie_value[:refresh_token],
      ),
    )
  rescue OidcClient::OAuthFailure
    # this means the refresh token has been revoked or the accounts
    # services are down
    logout!
    {}
  end

  def subscriber_list_options
    path = transition_checker_results_path(c: criteria_keys)

    {
      "title" => "Get ready for 2021",
      "description" => "[You can view a copy of your results on GOV.UK.](#{Plek.new.website_root}#{path})",
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
