class SessionsController < ApplicationController
  before_action :check_accounts_enabled

  def create
    if logged_in?
      redirect_to default_redirect_path
      return
    end

    redirect_if_not_test Services.oidc.auth_uri(redirect_path: params["redirect_path"])[:uri]
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
      cookies_policy = JSON.parse(cookies[:cookies_policy]).symbolize_keys
      cookies[:cookies_policy] = cookies_policy.merge(usage: true).to_json
    end

    redirect_if_not_test(callback[:redirect_path] || default_redirect_path)
  end

  def delete
    logout!
    redirect_if_not_test Plek.new.website_root
  end

protected

  def redirect_if_not_test(url)
    if Rails.env.test?
      render plain: "Redirecting to #{url}"
    else
      redirect_to url
    end
  end

  def default_redirect_path
    Plek.find("account-manager")
  end
end
