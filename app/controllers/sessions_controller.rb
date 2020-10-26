class SessionsController < ApplicationController
  before_action :check_accounts_enabled

  def create
    if logged_in?
      redirect_to default_redirect_path
      return
    end

    if Rails.env.test?
      render plain: "Redirecting to login"
    else
      redirect_to Services.oidc.auth_uri(redirect_path: params["redirect_path"])[:uri]
    end
  end

  def callback
    unless params[:code]
      redirect_to default_redirect_path
      return
    end

    state = params.require(:state)

    callback = Services.oidc.callback(
      params.require(:code),
      state,
    )

    tokens = callback[:access_token].token_response
    set_account_session_cookie(
      sub: callback[:sub],
      access_token: tokens[:access_token],
      refresh_token: tokens[:refresh_token],
    )

    if callback[:cookie_consent] && cookies[:cookies_policy]
      cookies_policy = JSON.decode(cookies[:cookies_policy]).symbolize_keys
      cookies[:cookies_policy] = cookies_policy.merge(usage: true).to_json
    end

    redirect_to callback[:redirect_path] || default_redirect_path
  end

  def delete
    logout!
    redirect_to default_redirect_path
  end

private

  def default_redirect_path
    transition_checker_questions_path
  end
end
