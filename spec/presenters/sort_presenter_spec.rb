require "spec_helper"

RSpec.describe SortPresenter do
  include GovukContentSchemaExamples

  subject(:presenter_without_sort) { described_class.new(content_item(sort_options: no_sort_options), values) }
  subject(:presenter_with_sort) { described_class.new(content_item(sort_options: sort_options_without_relevance), values) }
  subject(:presenter_with_default) { described_class.new(content_item(sort_options: sort_options_with_default), values) }
  subject(:presenter_with_popularity_default_and_relevance) { described_class.new(content_item(sort_options: sort_options_with_popularity_default_and_relevance), values) }
  subject(:presenter_with_relevance) { described_class.new(content_item(sort_options: sort_options_with_relevance), values) }
  subject(:presenter_with_relevance_selected) do
    described_class.new(
      content_item(sort_options: sort_options_with_relevance),
      "keywords" => "cats",
      "order" => "relevance",
    )
  end

  let(:values) { {} }

  let(:no_sort_options) { nil }

  let(:sort_options_without_relevance) do
    [
      { "name" => "Most viewed", "key" => "-popularity" },
      { "name" => "Updated (newest)", "key" => "-public_timestamp" },
    ]
  end

  let(:sort_options_with_relevance) do
    [
      { "name" => "Most viewed", "key" => "-popularity" },
      { "name" => "Updated (newest)", "key" => "-public_timestamp" },
      { "name" => "Relevance", "key" => "relevance" },
    ]
  end

  let(:sort_options_with_default) do
    [
      { "name" => "Most viewed", "key" => "-popularity" },
      { "name" => "Updated (oldest)", "key" => "-public_timestamp", "default" => true },
    ]
  end

  let(:sort_options_with_popularity_default_and_relevance) do
    [
      { "name" => "Most viewed", "key" => "-popularity", "default" => true },
      { "name" => "Relevance", "key" => "relevance" },
    ]
  end

  let(:sort_options_with_public_timestamp_default) do
    [
      { "name" => "Most viewed", "key" => "-popularity" },
      { "name" => "Updated (newest)", "key" => "-public_timestamp", "default" => true },
    ]
  end

  describe "#to_hash" do
    it "returns a hash containing options, default_value, and relevance_value" do
      expect(presenter_with_sort.to_hash).to eq(
        options: [
          {
            data_ga4_track_label: "Most viewed",
            label: "Most viewed",
            value: "most-viewed",
            disabled: false,
            selected: false,
          },
          {
            data_ga4_track_label: "Updated (newest)",
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
      expect(presenter_with_relevance_selected.to_hash[:options].find { |o| o[:selected] })
        .to eq(
          data_ga4_track_label: "Relevance",
          label: "Relevance",
          value: "relevance",
          disabled: false,
          selected: true,
        )
    end

    describe "disabling options based on keyword presence" do
      let(:relevance_option) { presenter_with_popularity_default_and_relevance.to_hash[:options].find { |o| o[:value] == "relevance" } }
      let(:popularity_option) { presenter_with_popularity_default_and_relevance.to_hash[:options].find { |o| o[:value] == "most-viewed" } }

      context "when keywords are blank" do
        let(:values) { { "keywords" => "" } }

        it "should disable the relevance option" do
          expect(relevance_option[:disabled]).to be true
          expect(relevance_option[:selected]).to be false
        end

        it "should enable the popularity option" do
          expect(popularity_option[:disabled]).to be false
          expect(popularity_option[:selected]).to be true
        end

        context "even when the relevance option is explicitly requested" do
          let(:values) { super().merge("order" => "relevance") }

          it "should still disable the relevance option" do
            expect(relevance_option[:disabled]).to be true
            expect(relevance_option[:selected]).to be false
          end

          it "should enable the popularity option" do
            expect(popularity_option[:disabled]).to be false
            expect(popularity_option[:selected]).to be true
          end
        end
      end

      context "when keywords are not blank" do
        let(:values) { { "keywords" => "something not blank" } }

        it "should not disable the relevance option" do
          expect(relevance_option[:disabled]).to be false
          expect(relevance_option[:selected]).to be true
        end

        it "should disable the popularity option" do
          expect(popularity_option[:disabled]).to be true
          expect(popularity_option[:selected]).to be false
        end

        context "even when the popularity option is explicitly requested" do
          let(:values) { super().merge("order" => "most-viewed") }

          it "should still disable the popularity option" do
            expect(popularity_option[:disabled]).to be true
            expect(popularity_option[:selected]).to be false
          end

          it "should enable the relevance option" do
            expect(relevance_option[:disabled]).to be false
            expect(relevance_option[:selected]).to be true
          end
        end
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
          data_ga4_track_label: "Updated (oldest)",
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
          "default" => true, "name" => "Updated (oldest)", "key" => "-public_timestamp",
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
