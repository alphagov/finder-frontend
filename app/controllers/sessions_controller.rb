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

    access_token = callback[:access_token]
    sub = callback[:sub]
    redirect_path = callback[:redirect_path] || default_redirect_path

    session[:has_session] = true
    session[:sub] = sub
    session[:access_token] = access_token.token_response[:access_token]
    session[:refresh_token] = access_token.token_response[:refresh_token]

    redirect_to redirect_path
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
