class ApplicationController < ActionController::Base
  include Slimmer::Template
  include Slimmer::GovukComponents
  slimmer_template "header_footer_only"

  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper :application
  rescue_from GdsApi::HTTPNotFound, with: :error_not_found

private

  def finder_base_path
    "/#{finder_slug}"
  end

  def finder_slug
    ab_test = GovukAbTesting::AbTest.new(
      "PolicyFinderTest",
      dimension: 65
    )

    @requested_variant = ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)

    params[:slug]
  end

  def error_not_found
    render status: :not_found, plain: "404 error not found"
  end
end
