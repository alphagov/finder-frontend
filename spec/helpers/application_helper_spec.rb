require "spec_helper"

RSpec.describe ApplicationHelper, type: :helper do
  describe "#search_component" do
    context "when ENV['GOVUK_DISABLE_SEARCH_AUTOCOMPLETE'] is not set" do
      it "returns 'search_with_autocomplete'" do
        ClimateControl.modify GOVUK_DISABLE_SEARCH_AUTOCOMPLETE: nil do
          expect(helper.search_component).to eq("search_with_autocomplete")
        end
      end
    end

    context "when ENV['GOVUK_DISABLE_SEARCH_AUTOCOMPLETE'] is set" do
      it "returns 'search'" do
        ClimateControl.modify GOVUK_DISABLE_SEARCH_AUTOCOMPLETE: "1" do
          expect(helper.search_component).to eq("search")
        end
      end
    end
  end
end
