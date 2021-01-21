class SessionsController < ApplicationController
  include AccountConcern

  before_action :handle_disabled, except: %i[delete], unless: :accounts_enabled?
  before_action :handle_offline, except: %i[delete], unless: :accounts_available?

  def create
    redirect_with_ga account_manager_url and return if logged_in?

    redirect_with_ga Services.oidc.auth_uri(redirect_path: params["redirect_path"])[:uri]
  end

  def callback
    redirect_to Plek.new.website_root and return unless params[:code]

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

    ephemeral_state =
      update_account_session_cookie_from_oauth_result(
        Services.oidc.get_ephemeral_state(
          access_token: tokens[:access_token],
          refresh_token: tokens[:refresh_token],
        ),
      )

    ga_client_id = ephemeral_state["_ga"]

    if ephemeral_state["cookie_consent"] && cookies[:cookies_policy]
      cookies_policy = JSON.parse(cookies[:cookies_policy]).symbolize_keys
      cookies[:cookies_policy] = cookies_policy.merge(usage: true).to_json
    end

    redirect_with_ga(callback[:redirect_path] || account_manager_url, ga_client_id)
  end

  def delete
    if params[:continue]
      logout!
      redirect_with_ga "#{account_manager_url}/sign-out?done=#{params[:continue]}"
    elsif params[:done]
      logout!
      redirect_with_ga "/transition"
    else
      redirect_with_ga "#{account_manager_url}/sign-out?continue=1"
    end
  end

protected

  def account_manager_url
    Plek.find("account-manager")
  end

  def redirect_with_ga(url, ga_client_id = nil)
    ga_client_id ||= params[:_ga]
    if ga_client_id
      url =
        if url.include? "?"
          "#{url}&_ga=#{ga_client_id}"
        else
          "#{url}?_ga=#{ga_client_id}"
        end
    end

    if Rails.env.test?
      render plain: "Redirecting to #{url}"
    else
      redirect_to url
    end
  end
end
