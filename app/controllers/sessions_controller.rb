require_relative "../lib/oidc_client.rb"

class SessionsController < ApplicationController
  def create
    if logged_in?
      redirect_to redirect_path
      return
    end

    redirect_to oidc.auth_uri[:uri]
  end

  def callback
    unless params[:code]
      redirect_to redirect_path
      return
    end

    state = params.require(:state)

    user_info = oidc.callback(
      params.require(:code),
      state,
    )

    session[:sub] = user_info.sub
    session[:email] = user_info.email

    redirect_to redirect_path
  end

  def delete
    session.delete(:sub)
    session.delete(:email)
    redirect_to redirect_path
  end

private

  def redirect_path
    transition_checker_questions_path
  end

  def oidc
    @oidc ||= OidcClient.new(
      Services.accounts_api,
      ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_ID"),
      ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_SECRET"),
    )
  end
end
