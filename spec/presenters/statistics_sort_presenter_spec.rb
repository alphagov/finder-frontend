require "spec_helper"

RSpec.describe StatisticsSortPresenter do
  let(:stats_finder) {
    ContentItem.new(JSON.parse(File.read(Rails.root.join("features", "fixtures", "statistics.json"))))
  }

  subject(:presenter_without_sort) { described_class.new(ContentItem.new("details" => { "sort_options" => [] }), {}) }
  subject(:presenter) { described_class.new(stats_finder, query) }
  let(:query) { {} }

  let(:keywords_query) { { "keywords" => "cats" } }

  let(:most_viewed_query) { { "order" => "most-viewed" } }

  let(:bad_sort_option_query) { { "order" => "blah blah" } }

  let(:published_statistics_query) do
    { "content_store_document_type" => "published_statistics" }
  end

  let(:upcoming_statistics_query) do
    { "content_store_document_type" => "upcoming_statistics" }
  end

  let(:research_query) do
    { "content_store_document_type" => "research" }
  end

  let(:cancelled_statistics_query) do
    { "content_store_document_type" => "cancelled_statistics" }
  end

  let(:default_option) {
    {
      "default" => true,
      "key" => "-public_timestamp",
      "name" => "Updated (newest)",
    }
  }

  describe "#has_options?" do
    it "returns false if there are no options in the content item" do
      expect(presenter_without_sort.to_hash).to be nil
    end

    it "returns true if there are sort options in the content item" do
      expect(presenter.to_hash).to_not be nil
    end
  end

  describe "#default_option and #default_value" do
    def expect_default(label, value)
      expect(presenter.default_option).to be_instance_of SortOptionPresenter
      expect(presenter.default_option.label).to eq label
      expect(presenter.default_value).to eq value
    end

    def expect_default_value(value)
      expect(presenter.default_value).to eq value
    end

    context "when published_statistics is selected" do
      let(:query) { published_statistics_query }
      it "returns updated newest" do
        expect_default("Updated (newest)", "updated-newest")
      end
    end

    context "when research is selected" do
      let(:query) { research_query }
      it "returns updated newest" do
        expect_default("Updated (newest)", "updated-newest")
      end
    end

    context "when upcoming_statistics is selected" do
      let(:query) { upcoming_statistics_query }
      it "returns release timestamp" do
        expect_default("Release date (soonest)", "release-date-oldest")
      end
    end

    context "when cancelled_statistics is selected" do
      let(:query) { cancelled_statistics_query }
      it "returns public timestamp" do
        expect_default("Updated (newest)", "updated-newest")
      end
    end

    context "when no value is selected" do
      it "returns updated newest as the default" do
        expect_default("Updated (newest)", "updated-newest")
      end
    end
  end

  describe "#selected_option" do
    def returns_the_default_option(option = default_option)
      expect(presenter.selected_option).to eq(option)
    end

    context "no option is selected by the user" do
      it "returns the default option" do
        returns_the_default_option
      end
    end

    context "a permitted option is selected by the user" do
      let(:query) { most_viewed_query }
      it "returns the permitted sort option" do
        expect(presenter.selected_option).to eq(
          "key" => "-popularity", "name" => "Most viewed",
        )
      end
    end

    context "an unpermitted option is selected by the user" do
      let(:order) { { "order" => "bad input!" } }

      it "returns the default option" do
        returns_the_default_option
      end

      context "published statistics is selected" do
        let(:query) { order.merge(published_statistics_query) }
        it "returns the default option" do
          returns_the_default_option
        end
      end

      context "upcoming statistics is selected" do
        let(:query) { order.merge(upcoming_statistics_query) }
        it "returns Release date (soonest)" do
          returns_the_default_option(
            "key" => "release_timestamp",
            "name" => "Release date (soonest)",
            "value" => "release-date-oldest",
          )
        end
      end

      context "cancelled statistics is selected" do
        let(:query) { order.merge(cancelled_statistics_query) }
        it "returns Updated (newest)" do
          returns_the_default_option(
            "default" => true,
            "key" => "-public_timestamp",
            "name" => "Updated (newest)",
          )
        end
      end

      context "research is selected" do
        let(:query) { order.merge(research_query) }
        it "returns the default option" do
          returns_the_default_option
        end
      end
    end

    context "Release date (latest) is selected by the user" do
      let(:order) { { "order" => "release-date-latest" } }
      let(:query) { order }

      it "returns Updated (newest)" do
        returns_the_default_option
      end

      context "upcoming statistics is selected" do
        let(:query) { order.merge(upcoming_statistics_query) }
        it "returns Release date (latest) as the default" do
          returns_the_default_option(
            "key" => "-release_timestamp",
            "name" => "Release date (latest)",
          )
        end
      end

      context "Updated (oldest) is selected by the user" do
        let(:order) { { "order" => "updated-oldest" } }
        let(:query) { order }

        it "returns Updated (oldest)" do
          returns_the_default_option(
            "key" => "public_timestamp",
            "name" => "Updated (oldest)",
          )
        end

        context "upcoming statistics is selected" do
          let(:query) { order.merge(upcoming_statistics_query) }
          it "returns Release date (soonest) as the default" do
            returns_the_default_option(
              "key" => "release_timestamp",
              "name" => "Release date (soonest)",
              "value" => "release-date-oldest",
            )
          end
        end
      end
    end

    context "Sort option release-date-oldest is selected by the user" do
      let(:order) { { "order" => "release-date-oldest" } }

      context "upcoming statistics is selected" do
        let(:query) { order.merge(upcoming_statistics_query) }
        it "returns Release date (soonest) as the default" do
          returns_the_default_option(
            "key" => "release_timestamp",
            "name" => "Release date (soonest)",
            "value" => "release-date-oldest",
          )
        end
      end

      context "cancelled statistics statistics is selected" do
        let(:query) { order.merge(cancelled_statistics_query) }
        it "returns Release date (oldest) as the default" do
          returns_the_default_option(
            "key" => "release_timestamp",
            "name" => "Release date (oldest)",
          )
        end
      end
    end
  end

  describe "#to_hash" do
    def default_value_is(value)
      expect(presenter.to_hash[:default_value]).to eq(value)
    end

    def relevance_value_is_set
      expect(presenter.to_hash[:relevance_value]).to eq("relevance")
    end

    def has_four_options
      expect(presenter.to_hash[:options].count).to eq(4)
    end

    def relevance_disabled?
      presenter.to_hash[:options].find { |o|
        o[:value] == "relevance"
      }[:disabled]
    end

    def relevance_is_disabled
      expect(relevance_disabled?).to be true
    end

    def relevance_is_enabled
      expect(relevance_disabled?).to be false
    end

    def release_timestamp_options_are_excluded
      no_release_timestamp_options = presenter.to_hash[:options].none? { |o|
        %w(release-date-oldest release-date-latest).include? o[:value]
      }

      expect(no_release_timestamp_options).to be true
    end

    def public_timestamp_options_are_excluded
      no_public_timestamp_options = presenter.to_hash[:options].none? { |o|
        %w(updated-newest updated-oldest).include? o[:value]
      }

      expect(no_public_timestamp_options).to be true
    end

    context "document group is unset" do
      it "provides a default value" do
        default_value_is("updated-newest")
      end

      it "has a relevance_value" do relevance_value_is_set; end

      it "has 4 options" do has_four_options; end

      it "excludes release timestamp options" do
        release_timestamp_options_are_excluded
      end

      context "keywords are not entered" do
        it "disables relevance" do relevance_is_disabled; end
      end

      context "keywords are entered" do
        let(:query) { keywords_query }
        it "enables relevance" do relevance_is_enabled; end
      end

      it "returns a hash containing an array of options" do
        expect(presenter.to_hash[:options]).to eq(
          [
            {
              data_track_action: "clicked",
              data_track_category: "dropDownClicked",
              data_track_label: "Most viewed",
              disabled: false,
              label: "Most viewed",
              selected: false,
              value: "most-viewed",
            },
            {
              data_track_action: "clicked",
              data_track_category: "dropDownClicked",
              data_track_label: "Relevance",
              disabled: true,
              label: "Relevance",
              selected: false,
              value: "relevance",
            },
            {
              data_track_action: "clicked",
              data_track_category: "dropDownClicked",
              data_track_label: "Updated (newest)",
              disabled: false,
              label: "Updated (newest)",
              selected: true,
              value: "updated-newest",
            },
            {
              data_track_action: "clicked",
              data_track_category: "dropDownClicked",
              data_track_label: "Updated (oldest)",
              disabled: false,
              label: "Updated (oldest)",
              selected: false,
              value: "updated-oldest",
            },
          ],
        )
      end

      it "sets the default option as selected" do
        expect(presenter.to_hash[:options].find { |o| o[:selected] }).
          to eq(
            data_track_category: "dropDownClicked",
            data_track_action: "clicked",
            data_track_label: "Updated (newest)",
            label: "Updated (newest)",
            value: "updated-newest",
            disabled: false,
            selected: true,
          )
      end
    end

    context "published_statistics is selected" do
      let(:query) { published_statistics_query }
      it "provides updated-newest as the default value" do
        default_value_is("updated-newest")
      end

      it "has a relevance_value" do relevance_value_is_set; end
      it "has 4 options" do has_four_options; end

      it "excludes release timestamp options" do
        release_timestamp_options_are_excluded
      end

      context "keywords are not entered" do
        it "disables relevance" do relevance_is_disabled; end
      end

      context "keywords are entered" do
        let(:query) { keywords_query.merge(published_statistics_query) }
        it "enables relevance" do relevance_is_enabled; end
      end
    end

    context "upcoming_statistics is selected" do
      let(:query) { upcoming_statistics_query }
      it "sets default_value" do default_value_is("release-date-oldest"); end
      it "sets relevance_value" do relevance_value_is_set; end
      it "has 4 options" do has_four_options; end

      it "excludes public timestamp options" do
        public_timestamp_options_are_excluded
      end

      context "keywords are not entered" do
        it "disables relevance" do relevance_is_disabled; end
      end

      context "keywords are entered" do
        let(:query) { keywords_query.merge(upcoming_statistics_query) }
        it "enables relevance" do relevance_is_enabled; end
      end
    end
  end
end
