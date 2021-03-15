class SessionsController < ApplicationController
  include AccountConcern

  before_action :handle_disabled, except: %i[delete], unless: :accounts_enabled?
  before_action :handle_offline, except: %i[delete], unless: :accounts_available?

  def create
    redirect_with_ga account_manager_url and return if logged_in?

    redirect_with_ga Services.account_api.get_sign_in_url(
      redirect_path: params[:redirect_path],
      state_id: params[:state],
    ).to_h["auth_uri"]
  end

  def callback
    redirect_to Plek.new.website_root and return unless params[:code]

    callback = Services.account_api.validate_auth_response(
      code: params.require(:code),
      state: params.require(:state),
    ).to_h

    set_account_session_header(callback["govuk_account_session"])

    redirect_with_ga(callback["redirect_path"] || account_manager_url, callback["ga_client_id"])
  rescue GdsApi::HTTPUnauthorized
    head :bad_request
  end

  def delete
    logout!
    if params[:continue]
      redirect_with_ga "#{account_manager_url}/sign-out?done=#{params[:continue]}"
    elsif params[:done]
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
