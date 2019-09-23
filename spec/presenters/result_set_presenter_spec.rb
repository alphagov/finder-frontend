require "spec_helper"
require_relative "./helpers/facets_helper"

RSpec.describe ResultSetPresenter do
  include FacetsHelper

  subject(:subject) {
    ResultSetPresenter.new(finder_presenter,
                           search_results,
                           filter_params,
                           sort_presenter,
                           metadata_presenter_class,
                           show_top_result,
                           debug_score)
  }

  let(:show_top_result) { false }
  let(:debug_score) { false }

  let(:finder_presenter) { FinderPresenter.new(content_item, facets) }

  let(:finder_content_id) { "content_id" }

  let(:content_item) {
    FactoryBot.build(:content_item,
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
                     })
  }

  let(:email_signup_hash) { nil }

  let(:facets) { [FactoryBot.build(:option_select_facet)] }

  let(:search_results) do
    ResultSetParser.parse(
      results.map(&:deep_stringify_keys),
      1,
      total_number_of_results,
)
  end

  let(:results) {
    (1..total_number_of_results).map { FactoryBot.build(:document_hash) }
  }

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
      let(:results) {
        [FactoryBot.build(:document_hash,
                          content_id: "content_id",
                          link: "/path/to/doc",
                          title: "document_title",
                          description_with_highlighting: "document_description")]
      }
      it "has the right data" do
        expected_hash = {
          link: {
            text: "document_title",
            path: "/path/to/doc",
            description: "document_description",
            data_attributes: {
              ecommerce_path: "/path/to/doc",
              ecommerce_content_id: "content_id",
              ecommerce_row: 1,
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
          highlight: false,
          highlight_text: nil,
        }

        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.first).to eql(expected_hash)
      end
    end

    context "with &debug_score=1" do
      let(:debug_score) { true }
      let(:results) {
        [FactoryBot.build(:document_hash, is_historic: true, es_score: 0.005, link: "/path/to/doc")]
      }
      let(:expected_document_content_with_debug) do
        "<span class=\"published-by\">First published during the 2015 Conservative government</span><span class=\"debug-results debug-results--link\">/path/to/doc</span><span class=\"debug-results debug-results--meta\">Score: 0.005</span><span class=\"debug-results debug-results--meta\">Format: answer</span>"
      end

      it "shows debug metadata" do
        search_result_objects = subject.search_results_content[:document_list_component_data]
        expect(search_result_objects.first[:subtext]).to eql(expected_document_content_with_debug)
      end
    end

    context "check top result" do
      let(:finder_content_id) { "42ce66de-04f3-4192-bf31-8394538e0734" } #brexit finder
      let(:show_top_result) { true }
      let(:filter_params) { { "order" => "relevance" } }
      let(:results) do
        [FactoryBot.build(:document_hash, es_score: 1.0, description_with_highlighting: "A description. With more text"),
         FactoryBot.build(:document_hash, es_score: 0.1, description_with_highlighting: "Another description")]
      end

      context "top result set if best bet (score > 7*other)" do
        it "has top result true" do
          search_result_objects = subject.search_results_content[:document_list_component_data]
          expect(search_result_objects[0][:highlight]).to be true
          expect(search_result_objects[0][:highlight_text]).to eql("Most relevant result")
          expect(search_result_objects[0][:link][:description]).to eql("A description.")
        end
      end

      context "top result not set if no best bet (score < 7*other)" do
        let(:results) do
          [FactoryBot.build(:document_hash, es_score: 1.0, description_with_highlighting: "A description. With more text"),
           FactoryBot.build(:document_hash, es_score: 0.5, description_with_highlighting: "Another description")]
        end
        it "has no top result" do
          search_result_objects = subject.search_results_content[:document_list_component_data]
          expect(search_result_objects[0][:highlight]).to_not eql(true)
        end
      end

      context "top result not set if show top result is false" do
        let(:show_top_result) { false }
        it "has no top result" do
          search_result_objects = subject.search_results_content[:document_list_component_data]
          expect(search_result_objects[0][:highlight]).to_not eql(true)
        end
      end
    end
  end
end
