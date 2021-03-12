# frozen_string_literal: true

module AccountConcern
  extend ActiveSupport::Concern

  ACCOUNT_SESSION_HEADER_INTERNAL_NAME = "HTTP_GOVUK_ACCOUNT_SESSION"
  ACCOUNT_SESSION_HEADER_NAME = "GOVUK-Account-Session"
  ACCOUNT_END_SESSION_HEADER_NAME = "GOVUK-Account-End-Session"
  ACCOUNT_SESSION_DEV_COOKIE_NAME = "govuk_account_session"

  included do
    before_action :fetch_account_session_header, if: :accounts_enabled?
    before_action :set_account_session_header, if: :accounts_enabled?
    before_action :set_account_variant, if: :accounts_enabled?

    helper_method :accounts_available?,
                  :accounts_enabled?,
                  :logged_in?

    attr_accessor :account_session_header
  end

  def accounts_enabled?
    Rails.configuration.feature_flag_govuk_accounts
  end

  def accounts_available?
    return false unless accounts_enabled?

    if @check_accounts_available.nil?
      @check_accounts_available = true
      begin
        RestClient.get(Plek.find("account-manager"))
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
    account_session_header.present?
  end

  def handle_disabled
    render status: :not_found, plain: "404 error not found"
  end

  def handle_offline
    redirect_to Plek.find("account-manager")
  end

  def fetch_account_session_header
    @account_session_header =
      if request.headers[ACCOUNT_SESSION_HEADER_INTERNAL_NAME]
        request.headers[ACCOUNT_SESSION_HEADER_INTERNAL_NAME]
      elsif request.headers.to_h[ACCOUNT_SESSION_HEADER_NAME]
        request.headers.to_h[ACCOUNT_SESSION_HEADER_NAME]
      elsif Rails.env.development?
        cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME]
      end
  end

  def show_signed_in_header?
    account_session_header.present?
  end

  def set_account_variant
    response.headers["Vary"] = [response.headers["Vary"], ACCOUNT_SESSION_HEADER_NAME].compact.join(", ")

    set_slimmer_headers(
      remove_search: true,
      show_accounts: show_signed_in_header? ? "signed-in" : "signed-out",
    )
  end

  def set_account_session_header(govuk_account_session = nil)
    @account_session_header = govuk_account_session if govuk_account_session
    response.headers[ACCOUNT_SESSION_HEADER_NAME] = @account_session_header

    if Rails.env.development?
      cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
        value: @account_session_header,
        domain: "dev.gov.uk",
      }
    end
  end

  def logout!
    response.headers[ACCOUNT_END_SESSION_HEADER_NAME] = "1"
    @account_session_header = nil

    if Rails.env.development?
      cookies[ACCOUNT_SESSION_DEV_COOKIE_NAME] = {
        value: "",
        domain: "dev.gov.uk",
        expires: 1.second.ago,
      }
    end
  end
end
