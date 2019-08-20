require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples
  include TaxonomySpecHelper

  subject(:presenter) { described_class.new(content_item, facets, {}, values) }
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

    it "returns facets with display_as_result_metadata" do
      expect(subject.metadata).to match_array([date_facet, option_facet])
    end

    it "returns correct keys for each facet type" do
      expect(subject.date_metadata_keys).to eq([date_facet.key])
      expect(subject.text_metadata_keys).to match_array([option_facet.key])
    end

    it "finds the name for the key key" do
      expect(subject.label_for_metadata_key("people")).to eql("Person")
      expect(subject.label_for_metadata_key("public_timestamp")).to eql("Public timestamp")
    end
  end

  describe 'url helpers' do
    let(:hidden_facet_hash) {
      {
        "filter_key": "hidden",
        "key": "topic",
        "type": "hidden",
        "filterable": true,
        "allowed_values": [{ "value" => "hidden_facet_content_id" }]
      }.deep_stringify_keys
    }

    let(:facets) {
      [HiddenFacet.new(hidden_facet_hash, facet_values)]
    }


    describe "#email_alert_signup_url" do
      context "with no values" do
        let(:facet_values) { [] }

        it "returns the finder URL appended with /email-signup" do
          expect(subject.email_alert_signup_url).to eql("https://www.gov.uk/mosw-reports/email-signup")
        end
      end

      context "with some values" do
        let(:email_alert_signup_options) {
          {
            "api_path": "/api/content/mosw-reports/email-signup",
            "base_path": "/mosw-reports/email-signup",
            "content_id": "12dd2b13-93ec-4ca6-a7a4-e2eb5f5d485a",
            "document_type": "finder_email_signup",
            "locale": "en",
            "public_updated_at": "2019-01-24T10:22:17Z",
            "schema_name": "finder_email_signup",
            "title": "MOSW reports",
            "withdrawn": false,
            "links": {},
            "api_url": "https://www.gov.uk/api/content/mosw-reports/email-signup",
            "web_url": "/mosw-reports/email-signup"
          }
        }

        let(:content_item) {
          create_content_item("links" => { "email_alert_signup" => [email_alert_signup_options] })
        }

        let(:facet_values) do
          %w[hidden_facet_content_id]
        end

        it "returns the finder URL appended with permitted query params" do
          expect(subject.email_alert_signup_url).to eql("/mosw-reports/email-signup?topic%5B%5D=hidden_facet_content_id")
        end
      end
    end

    describe "#atom_url" do
      context "with no values" do
        let(:facet_values) do
          []
        end
        it "returns the finder URL appended with .atom" do
          expect(subject.atom_url).to eql("/mosw-reports.atom")
        end
      end

      context "with some values" do
        let(:facet_values) do
          %w[hidden_facet_content_id]
        end

        it "returns the finder URL appended with permitted query params" do
          expect(subject.atom_url).to eql("/mosw-reports.atom?topic%5B%5D=hidden_facet_content_id")
        end
      end
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

  context "with all facet types" do
    let(:option_select_facet_hash) {
      {
        "filterable": true,
        "key": "people",
        "type": "text",
        "allowed_values": [{ "value" => "me" }, { "value" => "you" }]
      }.deep_stringify_keys
    }
    let(:taxon_facet_hash) {
      {
        "key": "_unused",
        "keys": %w[
            level_one_taxon
            level_two_taxon
          ],
        "type": "taxon",
        "filterable": true
      }.deep_stringify_keys
    }
    let(:date_facet_hash) {
      {
        "filterable": true,
        "key": "public_timestamp",
        "type": "date"
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
    let(:checkbox_facet_hash) {
      {
        "key": "checkbox",
        "filter_key": "checkbox",
        "filter_value": "filter_value",
        "type": "checkbox",
        "filterable": true,
      }.deep_stringify_keys
    }
    let(:radio_facet_hash) {
      {
        "key": "content_store_document_type",
        "type": "radio",
        "filterable": true,
        "option_lookup": {
          "statistics_published": %w[
              statistics
            ]
        },
        "allowed_values": [
          { "value": "statistics_published" }
        ]
      }.deep_stringify_keys
    }
    let(:hidden_clearable_facet_hash) {
      {
        "filterable": true,
        "key": "manual",
        "type": "hidden_clearable",
        "allowed_values": [{ "value" => "my_manual" }]
      }.deep_stringify_keys
    }

    let(:content_item) {
      create_content_item("details" => { "sort" => sort_without_relevance })
    }

    let(:facets) {
      [
        TaxonFacet.new(taxon_facet_hash, "level_one_taxon" => "taxon", "level_two_taxon" => ""),
        CheckboxFacet.new(checkbox_facet_hash, true),
        RadioFacet.new(radio_facet_hash, "type"),
        DateFacet.new(date_facet_hash, "from" => "21/11/2014", "to" => "21/11/2019"),
        OptionSelectFacet.new(option_select_facet_hash, %w[me you]),
        HiddenFacet.new(hidden_facet_hash, "hiding"),
        HiddenClearableFacet.new(hidden_clearable_facet_hash, %w[my_manual])
      ]
    }

    it 'returns all relevant query parameters' do
      topic_taxonomy_has_taxons([FactoryBot.build(:level_one_taxon_hash, content_id: 'taxon', title: 'taxon')])

      query_params = Rack::Utils.parse_nested_query URI.parse(subject.atom_url).query
      expect(query_params).to eq("checkbox" => "filter_value",
                                 "level_one_taxon" => "taxon",
                                 "level_two_taxon" => "",
                                 "public_timestamp" => { "from" => "21/11/2014", "to" => "21/11/2019" },
                                 "people" => %w[me you],
                                 "topic" => %w[hiding],
                                 "manual" => %w[my_manual])
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
