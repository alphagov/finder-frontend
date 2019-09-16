require 'spec_helper'

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples
  include TaxonomySpecHelper

  subject(:presenter) { described_class.new(content_item, facets, values) }
  let(:facets) { [] }
  let(:content_item) { create_content_item }
  let(:values) { {} }

  let(:sort_options_with_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" },
      { "name" => "Relevance", "key" => "relevance" }
    ]
  }

  let(:sort_without_relevance) {
    [
      { "name" => "Most viewed" },
      { "name" => "Updated (newest)" }
    ]
  }

  before { Rails.cache.clear }
  after { Rails.cache.clear }

  describe "facets" do
    let(:date_facet_hash) {
      {
        "filterable": true,
        "key": "public_timestamp",
        "type": "date",
        "display_as_result_metadata": "true"
      }.deep_stringify_keys
    }
    let(:option_select_facet_hash) {
      {
        "filterable": false,
        "key": "people",
        "short_name": "Person",
        "type": "text",
        "display_as_result_metadata": "true",
        "allowed_values": [{ "value" => "me" }, { "value" => "you" }],
      }.deep_stringify_keys
    }
    let(:hidden_facet_hash) {
      {
        "filter_key": "hidden",
        "key": "topic",
        "type": "hidden",
        "filterable": true,
        "allowed_values": [{ "value" => "hiding" }]
      }.deep_stringify_keys
    }
    let(:option_facet) {
      OptionSelectFacet.new(option_select_facet_hash, {})
    }
    let(:date_facet) {
      DateFacet.new(date_facet_hash, {})
    }
    let(:hidden_facet) {
      HiddenFacet.new(hidden_facet_hash, {})
    }
    let(:facets) {
      [date_facet, option_facet, hidden_facet]
    }
    it "returns the correct facets" do
      expect(subject.facets).to match_array(facets)
    end

    it "returns the filters that are filterable" do
      expect(subject.filters).to match_array([hidden_facet, date_facet])
    end
  end

  describe "#phase_message" do
    let(:message) { "Text with link <a href='https://gov.uk'>GOV.UK</a>" }

    context "phase is not set" do
      it "returns an empty string" do
        expect(subject.phase_message).to eql ""
      end
    end

    context "alpha message is set" do
      let(:content_item) { create_content_item("details" => { "alpha_message" => message }) }
      it "returns html_safe alpha message " do
        expect(subject.phase_message).to eql message
      end
    end

    context "beta message is set" do
      let(:content_item) { create_content_item("phase" => 'beta', "details" => { "beta_message" => message }) }
      it "returns html_safe beta message" do
        expect(subject.phase_message).to eql message
      end
    end
  end

  describe "#all_content_finder?" do
    it 'returns false by default' do
      expect(subject.all_content_finder?).to eq false
    end

    context "is all content finder" do
      let(:content_item) {
        create_content_item(content_id: "dd395436-9b40-41f3-8157-740a453ac972")
      }
      it 'returns true' do
        expect(subject.all_content_finder?).to eq true
      end
    end
  end

  describe "#eu_exit_finder?" do
    it 'returns false by default' do
      expect(subject.eu_exit_finder?).to eq false
    end

    context "is EU Exit finder" do
      let(:content_item) {
        create_content_item(content_id: "42ce66de-04f3-4192-bf31-8394538e0734")
      }
      it 'returns true' do
        expect(subject.eu_exit_finder?).to eq true
      end
    end
  end

  describe "#document_noun" do
    context "when is nil in content_item" do
      let(:content_item) {
        create_content_item("details" => { "document_noun" => nil })
      }
      it "should return a string" do
        expect(subject.document_noun).to eq("")
      end
    end

    context "when is set in content_item" do
      let(:content_item) {
        create_content_item("details" => { "document_noun" => "publication" })
      }

      it "should return the content item string" do
        expect(subject.document_noun).to eq("publication")
      end
    end
  end

private

  def create_content_item(options = {})
    finder_example = govuk_content_schema_example('finder').merge(options)

    dummy_http_response = double(
      "net http response",
      code: 200,
      body: finder_example.to_json,
      headers: {}
    )
    content_item_hash = GdsApi::Response.new(dummy_http_response).to_hash
    ContentItem.new(content_item_hash)
  end
end
