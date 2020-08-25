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

    callback = oidc.callback(
      params.require(:code),
      state,
    )

    access_token = callback[:access_token]
    sub = callback[:sub]

    session[:sub] = sub
    session[:access_token] = access_token.token_response[:access_token]

    redirect_to redirect_path
  end

  def delete
    session.delete(:sub)
    session.delete(:email)
    session.delete(:access_token)
    redirect_to redirect_path
  end

private

  def redirect_path
    transition_checker_questions_path
  end
end
