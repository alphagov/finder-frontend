class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::Template
  slimmer_template "header_footer_only"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application

  # rescue_from precedence is bottom up - https://stackoverflow.com/a/9121054/170864
  unless Rails.env.development?
    rescue_from GdsApi::BaseError, with: :error_503
    rescue_from GdsApi::InvalidUrl, with: :unprocessable_entity
    rescue_from GdsApi::HTTPNotFound, with: :error_not_found
    rescue_from GdsApi::HTTPForbidden, with: :forbidden
    rescue_from GdsApi::HTTPUnprocessableEntity, with: :unprocessable_entity
  end

  if ENV["REQUIRE_BASIC_AUTH"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

private

  def logout!
    cookies.delete account_session_cookie_name
  end

  def error_503(exception)
    error(503, exception)
  end

  def error(status_code, exception = nil)
    if exception
      GovukError.notify(exception)
    end

    render status: status_code, plain: "#{status_code} error"
  end

  def finder_base_path
    "/#{finder_slug}"
  end

  def finder_slug
    params[:slug]
  end

  def error_not_found
    render status: :not_found, plain: "404 error not found"
  end

  def forbidden
    render status: :forbidden, plain: "403 forbidden"
  end

  def unprocessable_entity
    render status: :unprocessable_entity, plain: "422 error: unprocessable entity"
  end

  def filter_params
    # TODO: Use a whitelist based on the facets in the schema
    @filter_params ||= begin
      permitted_params = params
                           .except(
                             :controller,
                             :action,
                             :slug,
                             :format,
                           )

      # Convert a query with 'q=search_term' into 'keywords=search_term'
      if permitted_params.key?("q")
        permitted_params["keywords"] = permitted_params.delete("q")
      end

      ParamsCleaner.new(permitted_params).cleaned
    end
  end

  def check_accounts_enabled
    unless accounts_enabled?
      render file: Rails.root.join(Rails.root, "public/404.html"), status: :not_found
    end
  end

  helper_method :accounts_enabled?
  def accounts_enabled?
    Rails.configuration.feature_flag_govuk_accounts
  end

  helper_method :logged_in?
  def logged_in?
    current_user.present?
  end

  def current_user
    account_session_cookie_value&.dig(:sub)
  end

  def account_session_cookie_name
    :"_finder-frontend_account_session"
  end

  def account_session_cookie_value
    value = cookies.encrypted[account_session_cookie_name]
    JSON.parse(value).symbolize_keys if value
  end

  def set_account_session_cookie(sub: nil, access_token: nil, refresh_token: nil)
    return unless accounts_enabled?
    return unless sub || account_session_cookie_value

    cookies.encrypted[account_session_cookie_name] = {
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
end
