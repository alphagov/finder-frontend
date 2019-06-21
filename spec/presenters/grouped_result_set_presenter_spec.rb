require 'spec_helper'

RSpec.describe GroupedResultSetPresenter do
  subject(:presenter) { GroupedResultSetPresenter.new(finder, filter_params, sort_presenter, metadata_presenter_class) }
  let(:metadata_presenter_class) do
    MetadataPresenter
  end
  let(:metadata) do
    [
      { id: 'case-state', name: 'Case state', value: 'Open', type: 'text', labels: %W(open) },
      { id: 'opened-date', name: 'Opened date', value: '2006-7-14', type: 'date' },
      { id: 'case-type', name: 'Case type', value: 'CA98 and civil cartels', type: 'text', labels: %W(ca98-and-civil-cartels) },
      { id: 'organisation_activity', name: 'Organisation activity', value: 'buying', type: 'text', labels: %W(buying) }
    ]
  end
  let(:formatted_metadata) do
    metadata_presenter_class.new(metadata).present
  end

  let(:filter_params) { { keywords: 'test' } }

  let(:finder) do
    double(
      FinderPresenter,
      slug: "/a-finder",
      name: 'A finder',
      results: results,
      document_noun: document_noun,
      sort_options: sort_presenter_without_options,
      total: 20,
      facets: a_facet_collection,
      keywords: keywords,
      atom_url: "/a-finder.atom",
      default_documents_per_page: 10,
      values: {},
      sort: {},
      filters: facet_filters
    )
  end

  let(:sort_presenter) { sort_presenter_without_options }

  let(:a_facet) do
    double(
      OptionSelectFacet,
      key: 'case-type',
      allowed_values: [
        {
          'value' => 'ca98-and-civil-cartels',
          'label' => 'CA98 and civil cartels'
        },
        {
          'value' => 'mergers',
          'label' => 'Mergers'
        },
      ],
      hide_facet_tag?: false,
    )
  end

  let(:results) do
    ResultSet.new(
      (1..total).map { document },
      total,
    )
  end

  let(:sort_presenter_without_options) do
    double(
      SortPresenter,
      has_options?: false,
      selected_option: nil,
      to_hash: {
        options: [],
        default_value: nil,
        relevance_value: nil,
      }
    )
  end

  let(:sort_presenter_with_options) do
    double(
      SortPresenter,
      has_options?: true,
      selected_option: { "name" => 'Relevance', "key" => '-relevance' },
      to_hash: {
        options: [
          {
            data_track_category: 'dropDownClicked',
            data_track_action: 'clicked',
            data_track_label: "Relevance",
            label: "Relevance",
            value: "relevance",
            disabled: false,
            selected: true,
          }
        ],
        default_value: nil,
        relevance_value: nil,
      },
    )
  end

  let(:document) do
    double(
      Document,
      title: 'Investigation into the distribution of road fuels in parts of Scotland',
      path: 'slug-1',
      metadata: metadata,
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
      show_metadata: false,
      format: 'transaction',
      es_score: nil
    )
  end

  let(:keywords) { '' }
  let(:document_noun) { 'case' }
  let(:total) { 20 }

  let(:facet_filters) { [sector_facet, activity_facet, a_facet] }
  let(:a_facet_collection) do
    double(
      FacetCollection,
      filters: facet_filters,
      first: facet_filters.first,
      find: nil,
      map: facet_filters.map { |f| [f.allowed_values] },
    )
  end

  let(:sector_facet) do
    double(
      OptionSelectFacet,
      key: 'sector_business_area',
      allowed_values: [
        { 'value' => 'aerospace', 'label' => 'Aerospace' },
        { 'value' => 'agriculture', 'label' => 'Agriculture' },
      ],
      hide_facet_tag?: false,
    )
  end

  let(:activity_facet) do
    double(
      OptionSelectFacet,
      key: 'organisation_activity',
      allowed_values: [
        { 'value' => 'products-or-goods', 'label' => 'Products or goods' },
        { 'value' => 'buying', 'label' => 'Buying' },
      ],
      hide_facet_tag?: false,
    )
  end

  before do
    allow(finder).to receive(:eu_exit_finder?).and_return(false)
  end

  describe "#grouped_documents" do
    let(:tagging_metadata) {
      [
        {
          id: 'sector_business_area',
          name: 'Sector / Organisation area',
          value: 'Aerospace',
          type: 'text',
          labels: %W(aerospace)
        },
        {
          id: 'business_activity',
          name: 'Organisation activity',
          value: 'Buying',
          type: 'text',
          labels: %W(buying)
        },
      ]
    }

    let(:formatted_tagged_metadata) {
      metadata_presenter_class.new(tagging_metadata).present
    }

    let(:tagged_document) {
      double(
        Document,
        title: 'Tagged to a primary facet',
        path: 'slug-3',
        metadata: tagging_metadata,
        summary: 'I am a document',
        is_historic: false,
        government_name: 'The Government',
        show_metadata: false,
        format: 'transaction',
        es_score: nil
      )
    }

    let(:primary_tagged_result) {
      SearchResultPresenter.new(tagged_document, formatted_tagged_metadata).to_hash
    }

    let(:document_result) { SearchResultPresenter.new(document, formatted_metadata).to_hash }

    context "when not grouping results" do
      let(:filter_params) { { order: 'a-z' } }
      let(:results) { ResultSet.new([document], total) }

      it "returns an empty array" do
        expect(subject.grouped_documents).to eq([])
      end
    end

    context "when no filters have been selected" do
      let(:filter_params) { { order: 'topic' } }
      let(:results) { ResultSet.new([document], total) }

      it "groups all documents in the default group" do
        expect(subject.grouped_documents).to eq([{
          facet_key: 'all_businesses',
          documents: subject.documents
        }])
      end

      it "does not populate the facet name for the group" do
        expect(subject.grouped_documents.first).not_to have_key(:facet_name)
      end
    end

    context "when only the primary facet has been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          sector_business_area: %W(aerospace),
        }
      }
      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "groups the relevant documents by the primary facet" do
        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Aerospace',
            facet_key: 'aerospace',
            documents: [{ document: primary_tagged_result, document_index: 2 }]
          }
        ])
      end
    end

    context "when primary and other facets have been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          sector_business_area: %W(aerospace),
          'case-type': %W(ca98-and-civil-cartels),
          'organisation_activity': %W(buying)
        }
      }

      let(:results) { ResultSet.new([document, tagged_document], total) }
      let(:facet_filters) { [sector_facet, a_facet, activity_facet] }

      it "orders the groups by facets in the other facets" do
        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Aerospace',
            facet_key: 'aerospace',
            documents: [{ document: primary_tagged_result, document_index: 2 }]
          },
          {
            facet_name: 'Case type',
            facet_key: 'case-type',
            documents: [{ document: document_result, document_index: 1 }]
          },
          {
            facet_name: 'Organisation activity',
            facet_key: 'organisation_activity',
            documents: [{ document: document_result, document_index: 1 }]
          },
        ])
      end
    end

    context "when other facets have been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          'organisation_activity': %W(buying),
          'personal-data': %W(digital-services)
        }
      }

      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "groups the relevant documents in the other facets" do
        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Organisation activity',
            facet_key: 'organisation_activity',
            documents: [{ document: document_result, document_index: 1 }]
          }
        ])
      end
    end

    context "when a document is tagged to all primary facets" do
      let(:tagging_metadata) {
        [{
          id: 'sector_business_area',
          name: 'Business area',
          value: 'Aerospace',
          type: 'text',
          labels: %W(aerospace agriculture)
        }]
      }

      let(:filter_params) {
        {
          order: 'topic',
          sector_business_area: %W(aerospace),
          'case-type': %W(ca98-and-civil-cartels)
        }
      }

      let(:results) { ResultSet.new([tagged_document], total) }

      it "is grouped in the default set" do
        allow(a_facet_collection).to receive(:find).and_return(sector_facet)

        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'All businesses',
            facet_key: 'all_businesses',
            documents: [{ document: primary_tagged_result, document_index: 1 }]
          }
        ])
      end
    end

    context "when primary facets have been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          sector_business_area: %W(aerospace),
          'case-type': %W(ca98-and-civil-cartels)
        }
      }
      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "groups the relevant documents in the primary facets" do
        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Aerospace',
            facet_key: 'aerospace',
            documents: [{ document: primary_tagged_result, document_index: 2 }]
          },
          {
            facet_name: 'Case type',
            facet_key: 'case-type',
            documents: [{ document: document_result, document_index: 1 }]
          },
        ])
      end
    end

    context "when other facets have been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          'case-type': %W(ca98-and-civil-cartels)
        }
      }

      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "groups the relevant documents in the other facets" do
        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Case type',
            facet_key: 'case-type',
            documents: [{ document: document_result, document_index: 1 }]
          }
        ])
      end
    end
  end

  describe "#grouped_display?" do
    context "a finder does not sort by topic" do
      let(:filter_params) { {} }
      let(:sort_presenter) { sort_presenter_without_options }
      before { allow(finder).to receive(:default_sort_option) }
      it "is false" do
        # allow(finder).to receive(:sort_options).and_return(sort_presenter_without_options)

        expect(subject.grouped_display?).to be false
      end
    end

    context "a finder sorts by topic" do
      let(:topic_sort_option) { { 'key' => 'topic', 'name' => 'Topic' } }
      let(:sort_presenter) { sort_presenter_with_options }

      before do
        # allow(finder).to receive(:sort_options).and_return(sort_presenter_with_options)
        allow(sort_presenter).to receive(:selected_option).and_return(topic_sort_option)
      end
      context "with no sort param" do
        let(:filter_params) { {} }
        it "is true" do
          expect(subject.grouped_display?).to be true
        end
      end
      context "with a 'topic' sort param" do
        let(:filter_params) { { order: 'topic' } }
        it "is true" do
          expect(subject.grouped_display?).to be true
        end
      end
      context "with a-z sort param" do
        let(:filter_params) { { order: 'a-z' } }
        it "is false" do
          expect(subject.grouped_display?).to be false
        end
      end
    end
  end

  context "when not grouping results" do
    let(:filter_params) { { order: 'a-z' } }
    let(:results) { ResultSet.new([document], total) }

    it "returns an empty array" do
      expect(subject.grouped_documents).to eq([])
    end
  end

  describe "#grouped_display?" do
    context "a finder does not sort by topic" do
      let(:filter_params) { {} }
      before { allow(finder).to receive(:default_option) }
      it "is false" do
        allow(finder).to receive(:sort).and_return([])

        expect(subject.grouped_display?).to be false
      end
    end

    context "a finder sorts by topic" do
      let(:topic_sort_option) { { 'key' => 'topic', 'name' => 'Topic' } }
      before do
        allow(sort_presenter).to receive(:selected_option).and_return(topic_sort_option)
      end
      context "with no sort param" do
        let(:filter_params) { {} }
        let(:sort_presenter) { sort_presenter_with_options }
        it "is true" do
          expect(subject.grouped_display?).to be true
        end
      end
      context "with a 'topic' sort param" do
        let(:filter_params) { { order: 'topic' } }
        it "is true" do
          expect(subject.grouped_display?).to be true
        end
      end
      context "with a-z sort param" do
        let(:filter_params) { { order: 'a-z' } }
        it "is false" do
          expect(subject.grouped_display?).to be false
        end
      end
    end
  end
end
