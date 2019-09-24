class ApplicationController < ActionController::Base
  include Slimmer::Headers
  include Slimmer::Template
  slimmer_template "header_footer_only"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application

  # rescue_from precedence is bottom up - https://stackoverflow.com/a/9121054/170864
  rescue_from GdsApi::BaseError, with: :error_503
  rescue_from GdsApi::InvalidUrl, with: :unprocessable_entity
  rescue_from GdsApi::HTTPNotFound, with: :error_not_found
  rescue_from GdsApi::HTTPUnprocessableEntity, with: :unprocessable_entity

  if ENV["REQUIRE_BASIC_AUTH"]
    http_basic_authenticate_with(
      name: ENV.fetch("BASIC_AUTH_USERNAME"),
      password: ENV.fetch("BASIC_AUTH_PASSWORD"),
    )
  end

private

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

  def unprocessable_entity
    render status: :unprocessable_entity, plain: "422 error: unprocessable entity"
  end

  def filter_params
    # TODO Use a whitelist based on the facets in the schema
    @filter_params ||= begin
      permitted_params = params
                           .except(
                             :controller,
                             :action,
                             :slug,
                             :format,
                           )

      # Convert a query with 'q=search_term' into 'keywords=search_term'
      if permitted_params.has_key?("q")
        permitted_params["keywords"] = permitted_params.delete("q")
      end

      ParamsCleaner.new(permitted_params).cleaned
    end
  end
end
