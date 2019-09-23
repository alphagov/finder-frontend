require "spec_helper"

RSpec.describe SortPresenter do
  include GovukContentSchemaExamples

  subject(:presenter_without_sort) { described_class.new(content_item(sort_options: no_sort_options), values) }
  subject(:presenter_with_sort) { described_class.new(content_item(sort_options: sort_options_without_relevance), values) }
  subject(:presenter_with_default) { described_class.new(content_item(sort_options: sort_options_with_default), values) }
  subject(:presenter_with_relevance) { described_class.new(content_item(sort_options: sort_options_with_relevance), values) }
  subject(:presenter_with_relevance_selected) {
    described_class.new(
      content_item(sort_options: sort_options_with_relevance),
      "keywords" => "cats", "order" => "relevance",
    )
  }

  let(:values) { {} }

  let(:no_sort_options) { nil }

  let(:sort_options_without_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" },
    ]
  }

  let(:sort_options_with_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" },
      { "name" => "Relevance", "key" => "relevance" },
    ]
  }

  let(:sort_options_with_default) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (oldest)", "default" => true },
    ]
  }

  let(:sort_options_with_public_timestamp_default) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)", "key" => "-public_timestamp", "default" => true },
    ]
  }

  describe "#to_hash" do
    it "returns a hash containing options, default_value, and relevance_value" do
      expect(presenter_with_sort.to_hash).to eq(
        options: [
          {
            data_track_category: "dropDownClicked",
            data_track_action: "clicked",
            data_track_label: "Most viewed",
            label: "Most viewed",
            value: "most-viewed",
            disabled: false,
            selected: false,
          },
          {
            data_track_category: "dropDownClicked",
            data_track_action: "clicked",
            data_track_label: "Updated (newest)",
            label: "Updated (newest)",
            value: "updated-newest",
            disabled: false,
            selected: false,
          },
        ],
        default_value: nil,
        relevance_value: nil,
      )
    end

    it "provides a default option if one is specified" do
      expect(presenter_with_default.to_hash[:default_value]).to eq("updated-oldest")
    end

    it "provides a relevance option if one is specified" do
      expect(presenter_with_relevance.to_hash[:relevance_value]).to eq("relevance")
    end

    it "sets an option as selected if a valid order is provided by the user" do
      expect(presenter_with_relevance_selected.to_hash[:options].find { |o| o[:selected] }).
        to eq(
          data_track_category: "dropDownClicked",
          data_track_action: "clicked",
          data_track_label: "Relevance",
          label: "Relevance",
          value: "relevance",
          disabled: false,
          selected: true,
        )
    end

    it "should disable the relevance option if keywords are not present" do
      expect(presenter_with_relevance.to_hash[:options].find { |o|
        o[:value] == "relevance"
      }[:disabled]).to be true
    end

    context "keywords are not blank" do
      let(:values) { { "keywords" => "something not blank" } }

      it "should not disable relevance" do
        expect(presenter_with_relevance.to_hash[:options].find { |o|
          o[:value] == "relevance"
        }[:disabled]).to be false
      end
    end

    it "returns nil when the finder doesn't have sort options" do
      expect(presenter_without_sort.to_hash).to eql(nil)
    end

    context "an unacceptable order is provided" do
      let(:values) { { "order" => "option_that_does_not_exist" } }
      it "no option is selected" do
        expect(presenter_with_sort.to_hash[:options].find { |o| o[:selected] }).to be nil
      end
    end

    context "order is not specified and default option exists" do
      it "returns sort options with default option selected" do
        expect(presenter_with_default.to_hash[:options].find { |o| o[:selected] }).to eql(
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (oldest)",
          disabled: false,
          label: "Updated (oldest)",
          selected: true,
          value: "updated-oldest",
        )
      end
    end
  end

  describe "#has_options?" do
    it "returns false if there are no options in the content item" do
      expect(presenter_without_sort.to_hash).to be nil
    end

    it "returns true if there are sort options in the content item" do
      expect(presenter_with_sort.to_hash).to_not be nil
    end
  end

  describe "#default_value" do
    it "returns a default_value if there is a default option specified in the content item" do
      expect(presenter_with_default.default_value).to eq("updated-oldest")
    end

    it "returns nil if there is not a default option specified in the content item" do
      expect(presenter_with_sort.default_value).to be nil
    end
  end

  describe "#selected_option" do
    context "an option is selected by the user" do
      it "returns a selected content item sort option" do
        expect(presenter_with_relevance_selected.selected_option).to eq(
          "key" => "relevance", "name" => "Relevance",
        )
      end
    end

    context "no option is selected by the user" do
      it "returns a default content item sort option" do
        expect(presenter_with_default.selected_option).to eq(
          "default" => true, "name" => "Updated (oldest)",
        )
      end
    end

    context "no default or selected option is available" do
      it "returns nil" do
        expect(presenter_with_relevance.selected_option).to be nil
      end
    end
  end

  describe "#default_option" do
    context "a default option is specified in the content item" do
      it "returns the default SortOptionPresenter" do
        expect(presenter_with_default.default_option).to be_instance_of(SortOptionPresenter)
        expect(presenter_with_default.default_option.label).to eq("Updated (oldest)")
      end
    end

    context "no default option is specified in the content item" do
      it "returns nil" do
        expect(presenter_with_relevance.default_option).to be nil
      end
    end
  end

private

  def content_item(sort_options: nil)
    finder_example = govuk_content_schema_example("finder")
    finder_example["details"]["sort"] = sort_options
    ContentItem.new(finder_example)
  end
end
