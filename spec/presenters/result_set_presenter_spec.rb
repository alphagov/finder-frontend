require "spec_helper"
require_relative "./helpers/facets_helper"

RSpec.describe ResultSetPresenter do
  include FacetsHelper

  subject(:subject) do
    ResultSetPresenter.new(
      content_item,
      facets,
      search_results,
      filter_params,
      sort_presenter,
      metadata_presenter_class,
      debug_score:,
      include_ecommerce: enable_ecommerce,
    )
  end

  let(:debug_score) { false }
  let(:enable_ecommerce) { true }

  let(:finder_content_id) { "content_id" }

  let(:content_item) do
    FactoryBot.build(
      :content_item,
      content_id: finder_content_id,
      base_path: "/a-finder",
      title: "A finder",
      links: {
        email_alert_signup: Array.wrap(email_signup_hash),
      },
      details: {
        show_summaries: true,
        document_noun: "case",
        sort: [
          {
            "name" => "Most viewed",
            "key" => "-popularity",
          },
          {
            "name" => "Relevance",
            "key" => "-relevance",
          },
          {
            "name" => "Updated (newest)",
            "key" => "-public_timestamp",
            "default" => true,
          },
        ],
        default_sort_option: {
          "name" => "Relevance",
          "key" => "-relevance",
        },
      },
    )
  end

  let(:email_signup_hash) { nil }

  let(:facets) { [FactoryBot.build(:option_select_facet)] }

  let(:search_results) do
    ResultSetParser.parse(
      "results" => results.map(&:deep_stringify_keys),
      "start" => 1,
      "total" => total_number_of_results,
    )
  end

  let(:results) do
    (1..total_number_of_results).map { FactoryBot.build(:document_hash) }
  end

  let(:total_number_of_results) { 5 }

  let(:filter_params) { {} }

  let(:sort_presenter) { SortPresenter.new(content_item, filter_params) }

  let(:metadata_presenter_class) do
    MetadataPresenter
  end

  describe "#displayed_total" do
    it "displays the total and the document noun" do
      FactoryBot.build(:option_select_facet, values: [1, 2, 3])
      expect(subject.displayed_total).to eql("#{total_number_of_results} cases")
    end
  end

  describe "#total_count" do
    it "displays the total count" do
      FactoryBot.build(:option_select_facet, values: [1, 2, 3])
      expect(subject.total_count).to eql(total_number_of_results)
    end
  end

  describe "#documents" do
    context "there is one document in the results" do
      let(:total_number_of_results) { 1 }

      it "creates a new search_result_presenter hash for each result" do
        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.count).to eql(total_number_of_results)
        expect(search_result_objects.first).to be_a(Hash)
      end
    end

    context "there are 3 documents in the results" do
      let(:total_number_of_results) { 3 }

      it "creates a new document for each result" do
        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.count).to eql(total_number_of_results)
      end
    end

    describe "#search_results_content[:document_list_component_data]" do
      let(:results) do
        [FactoryBot.build(
          :document_hash,
          content_id: "content_id",
          link: "/path/to/doc",
          title: "document_title",
          description_with_highlighting: "document_description",
        )]
      end
      it "has the right data" do
        expected_hash = {
          link: {
            text: "document_title",
            path: "/path/to/doc",
            description: "document_description",
            data_attributes: {
              ecommerce_path: "/path/to/doc",
              ga4_ecommerce_path: "/path/to/doc",
              ecommerce_row: 1,
              ecommerce_index: 1,
              track_category: "navFinderLinkClicked",
              track_action: "A finder.1",
              track_label: "/path/to/doc",
              track_options: {
                dimension28: 1,
                dimension29: "document_title",
              },
            },
          },
          metadata: {
            "Organisations" => "Organisations: Department for Work and Pensions",
          },
          metadata_raw: [
            {
              id: "organisations",
              label: "Organisations",
              value: "Department for Work and Pensions",
              labels: ["Department for Work and Pensions"],
              is_text: true,
            },
          ],
          subtext: nil,
          parts: [],
        }

        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.first).to eql(expected_hash)
      end
    end

    context "with &debug_score=1" do
      let(:debug_score) { true }
      let(:results) do
        [FactoryBot.build(:document_hash, is_historic: true, es_score: 0.005, link: "/path/to/doc")]
      end
      let(:expected_document_content_with_debug) do
        "<span class=\"published-by\">First published during the 2015 Conservative government</span><span class=\"debug-results debug-results--link\">/path/to/doc</span><span class=\"debug-results debug-results--meta\">Score: 0.005 (ranked #1)</span><span class=\"debug-results debug-results--meta\">Format: answer</span>"
      end

      it "shows debug metadata" do
        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.first[:subtext]).to eql(expected_document_content_with_debug)
      end
    end

    context "with universal analytics ecommerce disabled" do
      let(:enable_ecommerce) { false }
      let(:results) do
        [FactoryBot.build(
          :document_hash,
          content_id: "content_id",
          link: "/path/to/doc",
          title: "document_title",
          description_with_highlighting: "document_description",
        )]
      end

      it "doesn't include UA ecommerce attributes" do
        expected_hash = {
          link: {
            text: "document_title",
            path: "/path/to/doc",
            description: "document_description",
            data_attributes: {
              ga4_ecommerce_path: "/path/to/doc",
            },
          },
          metadata: {
            "Organisations" => "Organisations: Department for Work and Pensions",
          },
          metadata_raw: [
            {
              id: "organisations",
              label: "Organisations",
              value: "Department for Work and Pensions",
              labels: ["Department for Work and Pensions"],
              is_text: true,
            },
          ],
          subtext: nil,
          parts: [],
        }

        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.first).to eql(expected_hash)
      end
    end
  end

  describe "capitalise_ai_values function" do
    it "replaces 'Ai assurance technique' values with 'AI assurance technique" do
      component_data = [{
        "hello": "i should remain unchanged",
        "metadata": {
          "Ai assurance technique": "This is the text displayed on the search, Ai assurance technique",
        },
      }]

      # Clone the above search result, and then expect 'Ai' to be capitalised in the text displayed on search.
      expected_result = {}.merge!(component_data[0])
      expected_result[:metadata]["Ai assurance technique"] = "This is the text displayed on the search, AI assurance technique"

      component_data = subject.capitalise_ai_values(component_data)

      expect(component_data[0]).to eql expected_result
    end

    it "does nothing/doesn't crash if no 'Ai assurance technique' key exists" do
      component_data = [{
        "hello": "i should remain unchanged",
        "metadata": {
          "hello": "world",
        },
      }]

      # Clone the above search result
      expected_result = {}.merge!(component_data[0])

      component_data = subject.capitalise_ai_values(component_data)

      expect(component_data[0]).to eql expected_result
    end

    it "does nothing/doesn't crash if no metadata key exists" do
      component_data = [{
        "hello": "i should remain unchanged",
      }]

      # Clone the above search result
      expected_result = {}.merge!(component_data[0])

      component_data = subject.capitalise_ai_values(component_data)

      expect(component_data[0]).to eql expected_result
    end
  end
end
