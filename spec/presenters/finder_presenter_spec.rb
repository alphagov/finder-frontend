require 'spec_helper'
require "helpers/taxonomy_spec_helper"

RSpec.describe FinderPresenter do
  include GovukContentSchemaExamples
  include TaxonomySpecHelper

  subject(:presenter) { described_class.new(content_item(sort_options: no_sort_options), {}, values) }
  subject(:presenter_with_sort) { described_class.new(content_item(sort_options: sort_options_without_relevance), {}, values) }
  subject(:presenter_with_email_signup) { described_class.new(content_item(email_alert_signup: email_alert_signup_options), {}, values) }

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

  describe "#email_alert_signup_url" do
    context "with no values" do
      it "returns the finder URL appended with /email-signup" do
        expect(presenter.email_alert_signup_url).to eql("https://www.gov.uk/mosw-reports/email-signup")
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
        expect(presenter_with_email_signup.email_alert_signup_url).to eql("/mosw-reports/email-signup?place_of_origin%5B%5D=england")
      end
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
          place_of_origin: "england",
          walk_type: "open",
          creator: "Harry Potter",
          unpermitted_facet: "blah_blah",
        }
      end

      it "returns the finder URL appended with permitted query params" do
        expect(presenter.atom_url).to eql("/mosw-reports.atom?place_of_origin%5B%5D=england")
      end
    end

    context "with all facet types" do
      it 'returns all relevant query parameters' do
        option_select_facet_hash =   {
          "filterable": true,
          "key": "people",
          "type": "text",
          "allowed_values": [{ "value" => "me" }, { "value" => "you" }]
        }
        taxon_facet_hash = {
          "key": "_unused",
          "keys": %w[
            level_one_taxon
            level_two_taxon
          ],
          "type": "taxon",
          "filterable": true
        }
        date_facet_hash = {
          "filterable": true,
          "key": "public_timestamp",
          "type": "date"
        }
        hidden_facet_hash = {
          "filter_key": "hidden",
          "key": "topic",
          "type": "hidden",
          "filterable": true,
          "allowed_values": [{ "value" => "hiding" }]
        }
        checkbox_facet_hash = {
          "key": "checkbox",
          "filter_key": "checkbox",
          "filter_value": "filter_value",
          "type": "checkbox",
          "filterable": true,
        }
        radio_facet_hash = {
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
        hidden_clearable_facet_hash = {
          "filterable": true,
          "key": "manual",
          "type": "hidden_clearable",
          "allowed_values": [{ "value" => "my_manual" }]
        }

        topic_taxonomy_has_taxons([{ content_id: "taxon", title: "taxon" }])

        presenter = FinderPresenter.new(content_item(facets: [taxon_facet_hash,
                                                              checkbox_facet_hash,
                                                              radio_facet_hash,
                                                              date_facet_hash,
                                                              option_select_facet_hash,
                                                              hidden_facet_hash,
                                                              hidden_clearable_facet_hash]),
                                        [],
                                         'level_one_taxon' => "taxon",
                                          "checkbox" => true,
                                          "content_store_document_type" => "type",
                                          "public_timestamp" => { "from" => "21/11/2014", "to" => "21/11/2019" },
                                          "keywords" => "keyword",
                                          "people" => %w[me you],
                                          "topic" => "hiding",
                                          "manual" => "my_manual")
        query_params = Rack::Utils.parse_nested_query URI.parse(presenter.atom_url).query
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

  describe "#atom_feed_enabled?" do
    context "with no sort options and no default sort" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options: no_sort_options), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with default sort option set to descending public_timestamp" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options: sort_options_with_public_timestamp_default), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with sort options but no default order" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options: sort_options_with_relevance), values)
        expect(presenter.atom_feed_enabled?).to be true
      end
    end

    context "with no sort options but a changeable default order" do
      it "is false" do
        presenter = described_class.new(content_item(sort_options: no_sort_options, default_order: "relevance"), values)
        expect(presenter.atom_feed_enabled?).to be false
      end
    end

    context "with no sort options but a default order of most recent first" do
      it "is true" do
        presenter = described_class.new(content_item(sort_options: no_sort_options, default_order: "-public_timestamp"), values)
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
      expect(presenter.sort_options.to_hash[:options]).to eql([])
    end

    it "returns sort options without relevance when keywords is not present" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (newest)",
          disabled: false,
          label: "Updated (newest)",
          selected: false,
          value: "updated-newest",
        }
      ]

      expect(presenter_with_sort.sort_options.to_hash[:options]).to eql(expected_options)
    end

    it "returns sort options with relevance disabled when keywords is blank" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (newest)",
          disabled: false,
          label: "Updated (newest)",
          selected: false,
          value: "updated-newest"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Relevance",
          disabled: true,
          label: "Relevance",
          selected: false,
          value: "relevance"
        }
      ]

      presenter = described_class.new(content_item(sort_options: sort_options_with_relevance), {}, values)

      expect(presenter.sort_options.to_hash[:options]).to eql(expected_options)
    end

    it "returns sort options with relevance enabled when keywords is not blank" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (newest)",
          disabled: false,
          label: "Updated (newest)",
          selected: false,
          value: "updated-newest"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Relevance",
          disabled: false,
          label: "Relevance",
          selected: false,
          value: "relevance"
        }
      ]

      presenter = described_class.new(content_item(sort_options: sort_options_with_relevance), {}, "keywords" => "something not blank")

      expect(presenter.sort_options.to_hash[:options]).to eql(expected_options)
    end

    it "returns sort options with no option selected when order is specified but does not exist in options" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (newest)",
          disabled: false,
          label: "Updated (newest)",
          selected: false,
          value: "updated-newest"
        }
      ]

      presenter = described_class.new(content_item(sort_options: sort_options_without_relevance), "order" => "option_that_does_not_exist")

      expect(presenter.sort_options.to_hash[:options]).to eql(expected_options)
    end

    it "returns sort options with default option selected when order is not specified and default option exists" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (oldest)",
          disabled: false,
          label: "Updated (oldest)",
          selected: true,
          value: "updated-oldest"
        }
      ]

      presenter = described_class.new(content_item(sort_options: sort_options_with_default), values)

      expect(presenter.sort_options.to_hash[:options]).to eql(expected_options)
    end

    it "returns sort options with option selected when order is specified and exists in options" do
      expected_options = [
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Most viewed",
          disabled: false,
          label: "Most viewed",
          selected: false,
          value: "most-viewed"
        },
        {
          data_track_action: "clicked",
          data_track_category: "dropDownClicked",
          data_track_label: "Updated (newest)",
          disabled: false,
          label: "Updated (newest)",
          selected: true,
          value: "updated-newest"
        }
      ]

      presenter = described_class.new(content_item(sort_options: sort_options_without_relevance), {}, "order" => "updated-newest")

      expect(presenter.sort_options.to_hash[:options]).to eql(expected_options)
    end
  end

  context 'facets with content_ids' do
    let(:facets) do
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
    end

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

        presenter = described_class.new(content_item(facets: facets), [])
        expect(presenter.facet_details_lookup).to eq(expected)
      end

      context 'when a facet contains a short_name attribute' do
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
          presenter = described_class.new(content_item(facets: more_facets), [])
          expect(presenter.facet_details_lookup["5476f0c7-d029-459b-8a17-196374ae3366"]).to eq(
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

        presenter = described_class.new(content_item(facets: facets), [])
        expect(presenter.facet_value_lookup).to eq(expected)
      end
    end
  end

  describe "#all_content_finder?" do
    it 'returns true if finder is "All Content"' do
      subject.content_item["content_id"] = 'dd395436-9b40-41f3-8157-740a453ac972'
      expect(subject.all_content_finder?).to eq true
    end

    it 'returns false if finder is not "All Content"' do
      expect(subject.all_content_finder?).to eq false
    end
  end

  describe "#eu_exit_finder?" do
    it 'returns true if finder is eu_exit_finder' do
      subject.content_item["content_id"] = "42ce66de-04f3-4192-bf31-8394538e0734"
      expect(subject.eu_exit_finder?).to eq true
    end

    it 'returns false if finder is not eu_exit_finder' do
      expect(subject.eu_exit_finder?).to eq false
    end
  end

private

  def content_item(sort_options: nil, email_alert_signup: nil, default_order: nil, facets: nil)
    finder_example = govuk_content_schema_example('finder')
    finder_example['details']['sort'] = sort_options
    finder_example['details']['facets'] = facets if facets
    finder_example['links']['email_alert_signup'] = [email_alert_signup] if email_alert_signup
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
