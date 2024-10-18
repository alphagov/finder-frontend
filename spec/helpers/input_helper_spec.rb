require "spec_helper"

RSpec.describe InputHelper, type: :helper do
  describe "#date_input" do
    subject { helper.date_input(id, display_name, value) }

    let(:id) { "test_date" }
    let(:display_name) { "Test Date" }
    let(:value) { { day: "1", month: "1", year: "2023" } }

    it "renders a div with correct data attributes" do
      expect(subject).to have_css('div[data-ga4-section="Test Date"]')
    end

    it "renders the govuk_publishing_components date_input partial" do
      expect(helper).to receive(:render).with(
        "govuk_publishing_components/components/date_input",
        hash_including(
          id: "test_date",
          name: "test_date",
          legend_text: "Test Date",
          items: [
            { name: "day", width: 2, value: "1" },
            { name: "month", width: 2, value: "1" },
            { name: "year", width: 4, value: "2023" },
          ],
        ),
      )
      subject
    end

    context "with a legend suffix" do
      subject { helper.date_input(id, display_name, value, legend_suffix: "after") }

      it "includes the suffix in the legend text" do
        expect(helper).to receive(:render).with(
          "govuk_publishing_components/components/date_input",
          hash_including(
            legend_text: "Test Date after",
          ),
        )
        expect(subject).to have_css('div[data-ga4-section="Test Date after"]')
      end
    end

    context "with a hint" do
      subject { helper.date_input(id, display_name, value, hint: "For example, 13 12 1989") }

      it "passes the hint to the partial" do
        expect(helper).to receive(:render).with(
          "govuk_publishing_components/components/date_input",
          hash_including(hint: "For example, 13 12 1989"),
        )
        subject
      end
    end

    context "with an error message" do
      subject { helper.date_input(id, display_name, value, error_message:) }

      let(:error_message) { "Invalid date" }
      let(:expected_ga4_auto_data) do
        {
          event_name: "form_error",
          type: "finder",
          text: "Invalid date",
          section: "Test Date",
          action: "error",
          tool_name: "Search GOV.UK",
        }
      end

      it "adds GA4 data attributes for error tracking" do
        expect(subject).to have_css('div[data-module="ga4-auto-tracker"]')
        expect(subject).to have_css("div[data-ga4-auto='#{expected_ga4_auto_data.to_json}']")
      end

      it "passes the error message to the partial" do
        expect(helper).to receive(:render).with(
          "govuk_publishing_components/components/date_input",
          hash_including(error_message: "Invalid date"),
        )
        subject
      end
    end
  end
end
