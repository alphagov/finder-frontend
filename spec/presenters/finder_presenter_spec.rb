require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item(no_sort_options), values) }
  subject(:presenter_with_sort) { described_class.new(content_item(sort_options_without_relevance), values) }

  let(:no_sort_options) { nil }

  let(:sort_options_without_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" }
    ]
  }

  let(:sort_options_with_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" },
      { "name" => "Relevance", "key" => "relevance" }
    ]
  }

  let(:sort_options_with_default) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (oldest)", "default" => true }
    ]
  }

  let(:sort_options_with_public_timestamp_default) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)", "key" => "-public_timestamp", "default" => true }
    ]
  }

  let(:values) { {} }

  describe "facets" do
    it "returns the correct facets" do
      expect(subject.facets.count { |f| f.type == "date" }).to eql(1)
      expect(subject.facets.count { |f| f.type == "text" }).to eql(3)
    end

    it "returns the correct filters" do
      expect(subject.filters.length).to eql(2)
    end

    it "returns the correct metadata" do
      expect(subject.metadata.length).to eql(3)
    end

    it "returns correct keys for each facet type" do
      expect(subject.date_metadata_keys).to include("date_of_introduction")
      expect(subject.text_metadata_keys).to include("place_of_origin")
      expect(subject.text_metadata_keys).to include("walk_type")
    end
  end

  describe "#label_for_metadata_key" do
    it "finds the correct key" do
      expect(subject.label_for_metadata_key("date_of_introduction")).to eql("Introduced")
    end
  end

  describe "#atom_url" do
    context "with no values" do
      it "returns the finder URL appended with .atom" do
        expect(presenter.atom_url).to eql("/mosw-reports.atom")
      end
    end

    context "with some values" do
      let(:values) do
        {
          keyword: "legal",
          format: "publication",
          state: "open",
        }
      end

      it "returns the finder URL appended with .atom and query params" do
        expect(presenter.atom_url).to eql("/mosw-reports.atom?format=publication&keyword=legal&state=open")
      end
    end
  end

  describe "#atom_feed_enabled?" do
    context "with no sort options and no default sort" do
      it "is true" do
        presenter = described_class.new(content_item(no_sort_options), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with default sort option set to descending public_timestamp" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options_with_public_timestamp_default), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with sort options but no default order" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options_with_relevance), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with no sort options but a changeable default order" do
      it "is false" do
        presenter = described_class.new(content_item(no_sort_options, default_order: "relevance"), values)
        expect(presenter.atom_feed_enabled?).to be false
      end
    end

    context "with no sort options but a default order of most recent first" do
      it "is true" do
        presenter = described_class.new(content_item(no_sort_options, default_order: "-public_timestamp"), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end
  end

  describe "#sort_options" do
    def sort_option(label, value, disabled: false, selected: false)
      disabled_attr = disabled ? 'disabled="disabled" ' : ''
      selected_attr = selected ? 'selected="selected" ' : ''
      "<option data-track-category=\"dropDownClicked\" data-track-action=\"clicked\" data-track-label=\"#{label}\" #{disabled_attr}#{selected_attr}value=\"#{value}\">#{label}</option>"
    end

    it "returns an empty array when sort is not present" do
      expect(presenter.sort_options).to eql([])
    end

    it "returns sort options without relevance when keywords is not present" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest')
      ].join("\n")

      expect(presenter_with_sort.sort_options).to eql(expected_options)
    end

    it "returns sort options with relevance disabled when keywords is blank" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest'),
        sort_option('Relevance', 'relevance', disabled: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options_with_relevance), values)

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with relevance enabled when keywords is not blank" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest'),
        sort_option('Relevance', 'relevance', disabled: false)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options_with_relevance), "keywords" => "something not blank")

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with no option selected when order is specified but does not exist in options" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest')
      ].join("\n")


      presenter = described_class.new(content_item(sort_options_without_relevance), "order" => "option_that_does_not_exist")

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with default option selected when order is not specified and default option exists" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (oldest)', 'updated-oldest', selected: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options_with_default), values)

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with option selected when order is specified and exists in options" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest', selected: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options_without_relevance), "order" => "updated-newest")

      expect(presenter.sort_options).to eql(expected_options)
    end
  end

private

  def content_item(sort_options, default_order: nil)
    finder_example = govuk_content_schema_example('finder')
    finder_example['details']['sort'] = sort_options
    finder_example['details']['default_order'] = default_order if default_order

    dummy_http_response = double(
      "net http response",
      code: 200,
      body: finder_example.to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  end
end
