require "spec_helper"

RSpec.describe GovukChatPromoHelper, type: :helper do
  let(:base_path_with_chat_promo) { described_class::GOVUK_CHAT_PROMO_BASE_PATHS.first }

  describe "#show_govuk_chat_promo?" do
    it "returns false when ENV[GOVUK_CHAT_PROMO_ENABLED] isn't configured" do
      ClimateControl.modify GOVUK_CHAT_PROMO_ENABLED: "false" do
        expect(show_govuk_chat_promo?(base_path_with_chat_promo)).to be false
      end
    end

    it "returns false when base_path not in configuration" do
      ClimateControl.modify GOVUK_CHAT_PROMO_ENABLED: "true" do
        expect(show_govuk_chat_promo?("/non-matching-path")).to be false
      end
    end

    it "returns true when base_path is in configuration" do
      ClimateControl.modify GOVUK_CHAT_PROMO_ENABLED: "true" do
        expect(show_govuk_chat_promo?(base_path_with_chat_promo)).to be true
      end
    end
  end
end
