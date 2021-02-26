# frozen_string_literal: true

module AccountBrexitCheckerConcern
  extend ActiveSupport::Concern

  ACCOUNT_ACTIONS = %i[save_results save_results_sign_up save_results_confirm save_results_email_signup save_results_apply saved_results edit_saved_results].freeze

  included do
    # this is a false positive which will be fixed by updating rubocop
    # rubocop:disable Rails/LexicallyScopedActionFilter
    before_action :handle_disabled, only: ACCOUNT_ACTIONS, unless: :accounts_enabled?
    before_action :handle_offline, only: ACCOUNT_ACTIONS, unless: :accounts_available?
    before_action :pre_results, only: %i[results]
    before_action :pre_saved_results, only: %i[saved_results edit_saved_results]
    before_action :pre_update_results, only: %i[save_results_confirm save_results_apply]
    # rubocop:enable Rails/LexicallyScopedActionFilter
  end

  def pre_results
    results_in_account = oauth_fetch_results_from_account_or_logout
    return unless logged_in?

    now = Time.zone.now.to_i
    @results_differ = criteria_keys != results_in_account.fetch("criteria_keys", [])
    @results_saved = !@results_differ && results_in_account.fetch("timestamp", now) >= now - 10
  end

  def pre_saved_results
    results_in_account = oauth_fetch_results_from_account_or_logout
    redirect_to logged_out_pre_saved_results_path and return unless logged_in?

    @saved_results = results_in_account.fetch("criteria_keys", [])
  end

  def pre_update_results
    results_in_account = oauth_fetch_results_from_account_or_logout
    redirect_to logged_out_pre_update_results_path and return unless logged_in?

    @saved_results = results_in_account.fetch("criteria_keys", [])
  end

  def logged_out_pre_saved_results_path
    transition_checker_new_session_path(redirect_path: transition_checker_saved_results_path, _ga: params[:_ga])
  end

  def logged_out_pre_update_results_path
    transition_checker_new_session_path(redirect_path: transition_checker_save_results_confirm_path(c: criteria_keys), _ga: params[:_ga])
  end

  def oauth_fetch_results_from_account_or_logout
    oauth_do_or_logout do
      Services.oidc.get_checker_attribute(
        access_token: account_session_header_value[:access_token],
        refresh_token: account_session_header_value[:refresh_token],
      )
    end
  end

  def oauth_fetch_email_subscription_from_account_or_logout
    oauth_do_or_logout do
      Services.oidc.has_email_subscription(
        access_token: account_session_header_value[:access_token],
        refresh_token: account_session_header_value[:refresh_token],
      )
    end
  end

  def oauth_update_email_subscription_in_account_or_logout(slug)
    oauth_do_or_logout do
      Services.oidc.update_email_subscription(
        slug: slug,
        access_token: account_session_header_value[:access_token],
        refresh_token: account_session_header_value[:refresh_token],
      )
    end
  end

  def oauth_update_answers_in_account_or_logout(new_criteria_keys)
    oauth_do_or_logout do
      Services.oidc.set_checker_attribute(
        value: { criteria_keys: new_criteria_keys, timestamp: Time.zone.now.to_i },
        access_token: account_session_header_value[:access_token],
        refresh_token: account_session_header_value[:refresh_token],
      )
    end
  end

  def oauth_do_or_logout
    return unless account_session_header_value

    update_account_session_header_from_oauth_result yield
  rescue OidcClient::OAuthFailure
    logout!
  end
end
