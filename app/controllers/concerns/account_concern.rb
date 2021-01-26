module AccountConcern
  ACCOUNT_SESSION_COOKIE_NAME = :"_finder-frontend_account_session"

  def accounts_enabled?
    Rails.configuration.feature_flag_govuk_accounts
  end

  def accounts_available?
    return false unless accounts_enabled?

    if @check_accounts_available.nil?
      @check_accounts_available = true
      begin
        RestClient.get(Services.accounts_api)
      rescue RestClient::ServiceUnavailable
        @check_accounts_available = false
      rescue StandardError
        # Currently we're only guarding against planned 503 errors
        # In future we may want to selectively disable accounts if
        # a 5xx error rate gets too high, but that needs some more
        # thought first.
        @check_accounts_available = true
      end
    end
    @check_accounts_available
  end

  def logged_in?
    account_session_cookie_value&.dig(:sub).present?
  end

  def handle_disabled
    render status: :not_found, plain: "404 error not found"
  end

  def handle_offline
    redirect_to Services.accounts_api
  end

  def set_account_session_cookie(sub: nil, access_token: nil, refresh_token: nil)
    return unless sub || account_session_cookie_value

    cookies.encrypted[ACCOUNT_SESSION_COOKIE_NAME] = {
      value: {
        sub: sub || account_session_cookie_value&.dig(:sub),
        access_token: access_token || account_session_cookie_value&.dig(:access_token),
        refresh_token: refresh_token || account_session_cookie_value&.dig(:refresh_token),
      }.to_json,
      expires: 15.minutes,
      secure: Rails.env.production?,
    }
  end

  def update_account_session_cookie_from_oauth_result(result)
    set_account_session_cookie(
      access_token: result[:access_token],
      refresh_token: result[:refresh_token],
    )
    result[:result]
  end

  def account_session_cookie_value
    value = cookies.encrypted[ACCOUNT_SESSION_COOKIE_NAME]
    JSON.parse(value).symbolize_keys if value
  end

  def logout!
    cookies.delete ACCOUNT_SESSION_COOKIE_NAME
  end
end
