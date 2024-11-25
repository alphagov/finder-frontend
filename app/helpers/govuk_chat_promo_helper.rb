module GovukChatPromoHelper
  GOVUK_CHAT_PROMO_BASE_PATHS = %w[
    /business-finance-support
  ].freeze

  def show_govuk_chat_promo?(base_path)
    ENV["GOVUK_CHAT_PROMO_ENABLED"] == "true" && GOVUK_CHAT_PROMO_BASE_PATHS.include?(base_path)
  end
end
