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
      { "name" => "Updated (oldest)", "default" => "Updated (oldest)" }
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

  describe "#sort_options" do
    it "returns an empty array when sort is not present" do
      expect(presenter.sort_options).to eql([])
    end

    it "returns sort options without relevance when keywords is not present" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option value=\"updated-newest\">Updated (newest)</option>"

      expect(presenter_with_sort.sort_options).to eql(expected_options)
    end

    it "returns sort options with relevance disabled when keywords is blank" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option value=\"updated-newest\">Updated (newest)</option>\n<option disabled=\"disabled\" value=\"relevance\">Relevance</option>"

      presenter = described_class.new(content_item(sort_options_with_relevance), values)

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with relevance enabled when keywords is not blank" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option value=\"updated-newest\">Updated (newest)</option>\n<option value=\"relevance\">Relevance</option>"

      presenter = described_class.new(content_item(sort_options_with_relevance), "keywords" => "something not blank")

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with no option selected when order is specified but does not exist in options" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option value=\"updated-newest\">Updated (newest)</option>"

      presenter = described_class.new(content_item(sort_options_without_relevance), "order" => "option_that_does_not_exist")

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with default option selected when order is not specified and default option exists" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option selected=\"selected\" value=\"updated-oldest\">Updated (oldest)</option>"

      presenter = described_class.new(content_item(sort_options_with_default), values)

      expect(presenter.sort_options).to eql(expected_options)
    end

    it "returns sort options with option selected when order is specified and exists in options" do
      expected_options = "<option value=\"most-viewed\">Most viewed</option>\n<option selected=\"selected\" value=\"updated-newest\">Updated (newest)</option>"

      presenter = described_class.new(content_item(sort_options_without_relevance), "order" => "updated-newest")

      expect(presenter.sort_options).to eql(expected_options)
    end
  end

private

  def content_item(sort_options)
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
