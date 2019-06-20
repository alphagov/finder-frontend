# typed: false
require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples
  include TaxonomySpecHelper

  subject(:presenter) { described_class.new(content_item, {}, values) }
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

  describe "#email_alert_signup_url" do
    context "with no values" do
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

      let(:values) do
        {
          keyword: "legal",
          place_of_origin: "england",
          walk_type: "open",
          creator: "Harry Potter",
          unpermitted_facet: "blah_blah",
        }
      end

      it "returns the finder URL appended with permitted query params" do
        expect(subject.email_alert_signup_url).to eql("/mosw-reports/email-signup?place_of_origin%5B%5D=england")
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
        expect(subject.phase_message.html_safe?).to be true
      end
    end

    context "beta message is set" do
      let(:content_item) { create_content_item("phase" => 'beta', "details" => { "beta_message" => message }) }
      it "returns html_safe beta message" do
        expect(subject.phase_message).to eql message
        expect(subject.phase_message.html_safe?).to be true
      end
    end
  end

  describe "#atom_url" do
    context "with no values" do
      it "returns the finder URL appended with .atom" do
        expect(subject.atom_url).to eql("/mosw-reports.atom")
      end
    end

    context "with some values" do
      let(:values) do
        {
          keyword: "legal",
          place_of_origin: "england",
          walk_type: "open",
          creator: "Harry Potter",
          unpermitted_facet: "blah_blah",
        }
      end

      it "returns the finder URL appended with permitted query params" do
        expect(subject.atom_url).to eql("/mosw-reports.atom?place_of_origin%5B%5D=england")
      end
    end

    context "with all facet types" do
      let(:option_select_facet_hash) {
        {
          "filterable": true,
          "key": "people",
          "type": "text",
          "allowed_values": [{ "value" => "me" }, { "value" => "you" }]
        }
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
        }
      }
      let(:date_facet_hash) {
        {
          "filterable": true,
          "key": "public_timestamp",
          "type": "date"
        }
      }
      let(:hidden_facet_hash) {
        {
          "filter_key": "hidden",
          "key": "topic",
          "type": "hidden",
          "filterable": true,
          "allowed_values": [{ "value" => "hiding" }]
        }
      }
      let(:checkbox_facet_hash) {
        {
          "key": "checkbox",
          "filter_key": "checkbox",
          "filter_value": "filter_value",
          "type": "checkbox",
          "filterable": true,
        }
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
        }
      }
      let(:hidden_clearable_facet_hash) {
        {
          "filterable": true,
          "key": "manual",
          "type": "hidden_clearable",
          "allowed_values": [{ "value" => "my_manual" }]
        }
      }

      let(:content_item) {
        create_content_item(
          "details" => {
            "facets" => [
              taxon_facet_hash,
              checkbox_facet_hash,
              radio_facet_hash,
              date_facet_hash,
              option_select_facet_hash,
              hidden_facet_hash,
              hidden_clearable_facet_hash
            ],
            "sort" => sort_without_relevance
          }
        )
      }

      let(:values) {
        {
          'level_one_taxon' => "taxon",
          "checkbox" => true,
           "content_store_document_type" => "type",
           "public_timestamp" => { "from" => "21/11/2014", "to" => "21/11/2019" },
           "keywords" => "keyword",
           "people" => %w[me you],
           "topic" => "hiding",
           "manual" => "my_manual"
         }
      }

      it 'returns all relevant query parameters' do
        topic_taxonomy_has_taxons([{ content_id: "taxon", title: "taxon" }])

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
  end

  context 'facets with content_ids' do
    let(:facets) {
      [
        {
          'name' => 'Sector / Business area',
          'key' => 'sector_business_area',
          'allowed_values' => [
            { 'label' => 'Aerospace', 'value' => 'aerospace', 'content_id' => '14d51311-d182-40d0-85ea-8927d8b9bc91' },
            { 'label' => 'Agriculture', 'value' => 'agriculture', 'content_id' => 'ab38336f-09b9-4765-88f9-12c3fbebd20d' }
          ]
        },
        {
          'key' => 'intellectual_property',
          'name' => 'Intellectual property',
          'allowed_values' => [
            { 'label' => 'Copyright', 'value' => 'copyright', 'content_id' => '56dbec9a-1efd-4471-9f1d-51fcfd19e2db' }
          ]
        }
      ]
    }
    let(:content_item) {
      create_content_item("details" => { "facets" => facets })
    }

    describe '#facet_details_lookup' do
      it 'returns a hash of content_ids to facet details' do
        expected = {
          '14d51311-d182-40d0-85ea-8927d8b9bc91' => {
            id: 'sector_business_area',
            key: 'sector_business_area',
            name: 'Sector / Business area',
            type: 'content_id',
          },
          'ab38336f-09b9-4765-88f9-12c3fbebd20d' => {
            id: 'sector_business_area',
            key: 'sector_business_area',
            name: 'Sector / Business area',
            type: 'content_id',
          },
          '56dbec9a-1efd-4471-9f1d-51fcfd19e2db' => {
            id: 'intellectual_property',
            key: 'intellectual_property',
            name: 'Intellectual property',
            type: 'content_id',
          }
        }

        expect(subject.facet_details_lookup).to eq(expected)
      end

      context 'when a facet contains a short_name attribute' do
        let(:content_item) { create_content_item("details" => { "facets" => more_facets }) }
        let(:more_facets) do
          facets <<
            {
              'key' => 'employ_eu_citizens',
              'name' => 'Who you employ',
              'short_name' => 'Employing EU citizens',
              'allowed_values' => [
                { 'label' => 'EU citizens', 'value' => 'yes', 'content_id' => '5476f0c7-d029-459b-8a17-196374ae3366' }
              ]
            }
        end

        it 'overrides the facet name in the details lookup' do
          expect(subject.facet_details_lookup["5476f0c7-d029-459b-8a17-196374ae3366"]).to eq(
            id: "employ_eu_citizens", key: "employ_eu_citizens", name: "Employing EU citizens", type: "content_id"
          )
        end
      end
    end

    describe '#facet_value_lookup' do
      it 'returns a hash of content_ids to facet values' do
        expected = {
          '14d51311-d182-40d0-85ea-8927d8b9bc91' => 'aerospace',
          'ab38336f-09b9-4765-88f9-12c3fbebd20d' => 'agriculture',
          '56dbec9a-1efd-4471-9f1d-51fcfd19e2db' => 'copyright'
        }

        expect(subject.facet_value_lookup).to eq(expected)
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
    GdsApi::Response.new(dummy_http_response).to_hash
  end
end
