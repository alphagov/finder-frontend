class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::Template

  slimmer_template "gem_layout"

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
    rescue_from ActionController::BadRequest, with: :bad_request
  end

  if ENV["REQUIRE_BASIC_AUTH"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

private

  def content_item
    @content_item ||= ContentItem.from_content_store(finder_base_path)
  end

  def set_expiry(content_item)
    unless Rails.env.development?
      public_cache = content_item.as_hash.dig("cache_control", "public")

      expires_in(
        content_item.as_hash.dig("cache_control", "max_age") || 5.minutes.to_i,
        public: public_cache.nil? || public_cache,
      )
    end
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

  def bad_request
    render status: :bad_request, plain: "400 error: bad request"
  end

  def filter_params
    @filter_params ||= ParamsCleaner.call(params)
  end
end
