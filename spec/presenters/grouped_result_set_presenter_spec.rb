require "spec_helper"

RSpec.describe GroupedResultSetPresenter do
  subject(:presenter) { GroupedResultSetPresenter.new(finder_presenter, search_results, filter_params, sort_presenter, metadata_presenter_class) }

  let(:metadata_presenter_class) do
    MetadataPresenter
  end

  let(:content_item) {
    FactoryBot.build(:content_item, finder_name: finder_name)
  }

  let(:finder_name) { "A finder" }

  let(:finder_presenter) do
    FinderPresenter.new(content_item, facets)
  end

  let(:sort_presenter) { SortPresenter.new(content_item, filter_params.deep_stringify_keys) }

  let(:facets) { [first_facet, second_facet, third_facet] }

  let(:first_facet) do
    FactoryBot.build(:option_select_facet,
                     key: "first_facet_key",
                     short_name: "Primary Facet Short Name",
                     allowed_values: [
                       {
                         "value" => "first_value_1",
                         "label" => "Primary Label 1",
                         "content_id" => "first_value_1_content_id",
                       },
                       {
                         "value" => "first_value_2",
                         "label" => "Primary Label 2",
                         "content_id" => "first_value_2_content_id",
                       },
                     ])
  end

  let(:second_facet) do
    FactoryBot.build(:option_select_facet,
                     key: "second_facet_key",
                     short_name: "Secondary Facet Short Name",
                     allowed_values: [
                       {
                         "value" => "second_value_1",
                         "label" => "secondary Label 1",
                         "content_id" => "second_value_1_content_id",
                       },
                       {
                         "value" => "second_value_2",
                         "label" => "Secondary Label 2",
                         "content_id" => "second_value_2_content_id",
                       },
                     ])
  end

  let(:third_facet) do
    FactoryBot.build(:option_select_facet,
                     key: "third_facet_key",
                     short_name: "Tertiary Facet Short Name",
                     allowed_values: [
                       {
                         "value" => "third_value_1",
                         "label" => "tertiary Label 1",
                         "content_id" => "third_value_1_content_id",
                       },
                       {
                         "value" => "third_value_2",
                         "label" => "Tertiary Label 2",
                         "content_id" => "third_value_2_content_id",
                       },
                     ])
  end

  describe "#grouped_documents" do
    def build_document_list_component(document, all_documents_count)
      SearchResultPresenter.new(document: document,
                                metadata_presenter_class: metadata_presenter_class,
                                doc_count: all_documents_count,
                                content_item: content_item,
                                facets: facets,
                                debug_score: false,
                                highlight: false).document_list_component_data
    end

    context "Ordering is not set to topic, so there is no grouping" do
      let(:filter_params) { { order: "a-z" } }
      let(:search_results) { ResultSetParser.parse([FactoryBot.build(:document_hash)], 0, 1) }

      it "returns an empty array" do
        expect(subject.search_results_content[:grouped_document_list_component_data]).to be_empty
      end
    end

    context "The user has not selected any facets" do
      let(:filter_params) { { order: "topic" } }
      let(:search_results) {
        document = FactoryBot.build(:document_hash,
                                    facet_values: %w[first_value_1_content_id
                                                     second_value_1_content_id
                                                     third_value_1_content_id])
        ResultSetParser.parse([document], 0, 1)
      }

      it "groups all documents in the default group" do
        expect(subject.search_results_content[:grouped_document_list_component_data]).
          to eq([{
                   documents: subject.search_results_content[:document_list_component_data],
                 }])
      end

      it "does not populate the facet name for the group" do
        expect(subject.search_results_content[:grouped_document_list_component_data].first).not_to have_key(:group_name)
      end
    end

    context "The user has not selected only the primary facet" do
      let(:filter_params) {
        {
          order: "topic",
          first_facet_key: %W(first_value_1),
        }
      }
      let(:document_hash) {
        FactoryBot.build(:document_hash,
                         facet_values: %w[
                           first_value_1_content_id
                           second_value_1_content_id
                           third_value_1_content_id
                          ])
      }

      let(:search_results) { ResultSetParser.parse([document_hash], 0, 5) }

      let(:document) {
        Document.new(document_hash, 1)
      }

      it "groups the relevant documents by the primary facet" do
        expect(subject.search_results_content[:grouped_document_list_component_data]).
          to eq([
                  {
                    group_name: "Primary Label 1",
                    documents: [build_document_list_component(document, 1)],
                  },
                ])
      end
    end

    context "when primary and other facets have been selected" do
      let(:tagged_to_first_facet_document_hash) {
        FactoryBot.build(:document_hash,
                         facet_values: %w[
                           first_value_1_content_id
                         ])
      }
      let(:tagged_to_second_and_third_facet_document_hash) {
        FactoryBot.build(:document_hash,
                         facet_values: %w[
                           second_value_1_content_id
                           third_value_1_content_id
                          ])
      }

      let(:search_results) {
        ResultSetParser.parse([
                                tagged_to_first_facet_document_hash,
                                tagged_to_second_and_third_facet_document_hash,
                              ], 0, 5)
      }

      let(:tagged_to_first_facet_document) {
        Document.new(tagged_to_first_facet_document_hash, 1)
      }
      let(:tagged_to_second_and_third_facet_document) {
        Document.new(tagged_to_second_and_third_facet_document_hash, 2)
      }

      let(:filter_params) {
        {
          order: "topic",
          first_facet_key: %W(first_value_1),
          second_facet_key: %W(second_value_1),
          third_facet_key: %W(third_value_1),
        }
      }

      it "orders the groups by facets in the other facets" do
        expect(subject.search_results_content[:grouped_document_list_component_data]).
          to eq([
                  {
                    group_name: "Primary Label 1",
                    documents: [build_document_list_component(tagged_to_first_facet_document, 2)],
                  },
                  {
                    group_name: "Secondary Facet Short Name",
                    documents: [build_document_list_component(tagged_to_second_and_third_facet_document, 2)],
                  },
                  {
                    group_name: "Tertiary Facet Short Name",
                    documents: [build_document_list_component(tagged_to_second_and_third_facet_document, 2)],
                  },

                ])
      end
    end

    context "when a document is tagged to all primary facet values" do
      let(:document_hash) {
        FactoryBot.build(:document_hash,
                         facet_values: %w[
                           first_value_1_content_id first_value_2_content_id
                         ])
      }
      let(:filter_params) {
        {
          order: "topic",
          first_facet_key: %W(first_value_1),
        }
      }

      let(:search_results) {
        ResultSetParser.parse([document_hash], 0, 5)
      }
      let(:document) {
        Document.new(document_hash, 1)
      }

      it "is grouped in the default set" do
        expect(subject.search_results_content[:grouped_document_list_component_data]).
          to eq([
                  {
                    group_name: "All businesses",
                    documents: [build_document_list_component(document, 1)],
                  },
                ])
      end
    end
  end

  describe "#grouped_display?" do
    let(:document_hash) {
      FactoryBot.build(:document_hash)
    }

    let(:search_results) { ResultSetParser.parse([document_hash], 0, 5) }

    subject(:grouped_display) {
      GroupedResultSetPresenter.new(finder_presenter, search_results, filter_params, sort_presenter, metadata_presenter_class).
        search_results_content[:display_grouped_results]
    }

    context "a finder sorts by topic" do
      context "with no sort param" do
        let(:filter_params) { {} }
        it "is true" do
          expect(grouped_display).to be true
        end
      end
      context "with a 'topic' sort param" do
        let(:filter_params) { { "order" => "topic" } }
        it "is true" do
          expect(grouped_display).to be true
        end
      end
      context "with non-topic sort param" do
        let(:filter_params) { { order: "most-viewed" } }
        it "is false" do
          expect(grouped_display).to be false
        end
      end
    end
  end
end
