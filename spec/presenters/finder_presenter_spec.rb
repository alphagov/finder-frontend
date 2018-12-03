require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples

  subject(:presenter) { described_class.new(content_item, values) }

  let(:content_item) {
    finder_example = govuk_content_schema_example('finder')
    finder_example['details']['sort'] = nil

    dummy_http_response = double(
      "net http response",
        code: 200,
        body: finder_example.to_json,
        headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
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
end
