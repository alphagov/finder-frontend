require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe SortPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item(sort_options: no_sort_options), {}) }
  subject(:presenter_without_sort) { described_class.new(content_item(sort_options: no_sort_options), {}) }
  subject(:presenter_with_sort) { described_class.new(content_item(sort_options: sort_options_without_relevance), {}) }
  subject(:presenter_with_default) { described_class.new(content_item(sort_options: sort_options_with_default), {}) }

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

  describe "#for_select" do
    def sort_option(label, value, disabled: false, selected: false)
      disabled_attr = disabled ? 'disabled="disabled" ' : ''
      selected_attr = selected ? 'selected="selected" ' : ''
      "<option data-track-category=\"dropDownClicked\" data-track-action=\"clicked\" data-track-label=\"#{label}\" #{disabled_attr}#{selected_attr}value=\"#{value}\">#{label}</option>"
    end

    it "returns an empty string when sort is not present" do
      expect(presenter_without_sort.for_select).to eql("")
    end

    it "returns sort options without relevance when keywords is not present" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest')
      ].join("\n")

      expect(presenter_with_sort.for_select).to eql(expected_options)
    end

    it "returns sort options with relevance disabled when keywords is blank" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest'),
        sort_option('Relevance', 'relevance', disabled: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options: sort_options_with_relevance), {})

      expect(presenter.for_select).to eql(expected_options)
    end

    it "returns sort options with relevance enabled when keywords is not blank" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest'),
        sort_option('Relevance', 'relevance', disabled: false)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options: sort_options_with_relevance), "keywords" => "something not blank")

      expect(presenter.for_select).to eql(expected_options)
    end

    it "returns sort options with no option selected when order is specified but does not exist in options" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest')
      ].join("\n")


      presenter = described_class.new(content_item(sort_options: sort_options_without_relevance), "order" => "option_that_does_not_exist")

      expect(presenter.for_select).to eql(expected_options)
    end

    it "returns sort options with default option selected when order is not specified and default option exists" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (oldest)', 'updated-oldest', selected: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options: sort_options_with_default), {})

      expect(presenter.for_select).to eql(expected_options)
    end

    it "returns sort options with option selected when order is specified and exists in options" do
      expected_options = [
        sort_option('Most viewed', 'most-viewed'),
        sort_option('Updated (newest)', 'updated-newest', selected: true)
      ].join("\n")

      presenter = described_class.new(content_item(sort_options: sort_options_without_relevance), "order" => "updated-newest")

      expect(presenter.for_select).to eql(expected_options)
    end
  end

  describe "#has_options?" do
    it "returns false if there are no options in the content item" do
      expect(presenter_without_sort.has_options?).to be false
    end

    it "returns true if there are sort options in the content item" do
      expect(presenter_with_sort.has_options?).to be true
    end
  end

  describe "#has_default_option?" do
    it "returns true if there is a default option specified in the content item" do
      expect(presenter_with_default.has_default_option?).to be true
    end

    it "returns false if there is not a default option specified in the content item" do
      expect(presenter_with_sort.has_default_option?).to be false
    end
  end

  describe "#has_default_option?" do
    it "returns true if there is a default option specified in the content item" do
      expect(presenter_with_default.has_default_option?).to be true
    end

    it "returns false if there is not a default option specified in the content item" do
      expect(presenter_with_sort.has_default_option?).to be false
    end
  end

  describe "#default_option" do
    it "returns a default SortOptionPresenter if there is a default option specified in the content item" do
      expect(presenter_with_default.default_option).to be_instance_of(SortOptionPresenter)
      expect(presenter_with_default.default_option.label).to eq("Updated (oldest)")
    end

    it "returns nil if there is not a default option specified in the content item" do
      expect(presenter_with_sort.default_option).to be nil
    end
  end

  describe "#find_by_value" do
    it "returns a SortOptionPresenter if there is an option with that value" do
      expect(presenter_with_default.find_by_value("updated-oldest")).to be_instance_of(SortOptionPresenter)
      expect(presenter_with_default.find_by_value("updated-oldest").label).to eq("Updated (oldest)")
    end

    it "returns nil if there is no option with that value" do
      expect(presenter_with_sort.find_by_value("blah blah blah")).to be nil
    end
  end

private

  def content_item(sort_options: nil)
    finder_example = govuk_content_schema_example('finder')
    finder_example['details']['sort'] = sort_options

    dummy_http_response = double(
      "net http response",
      code: 200,
      body: finder_example.to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  end
end
