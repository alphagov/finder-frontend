require 'spec_helper'

RSpec.describe GroupedResultSetPresenter do
  subject(:presenter) { GroupedResultSetPresenter.new(finder, filter_params, view_context) }

  let(:pagination) { { 'current_page' => 1, 'total_pages' => 2 } }

  let(:filter_params) { { keywords: 'test' } }

  let(:view_context) { double(:view_context) }

  let(:finder) do
    double(
      FinderPresenter,
      slug: "/a-finder",
      name: 'A finder',
      results: results,
      document_noun: document_noun,
      total: 20,
      facets: a_facet_collection,
      keywords: keywords,
      atom_url: "/a-finder.atom",
      default_documents_per_page: 10,
      values: {},
      pagination: pagination,
      sort: {},
      filters: {}
    )
  end

  let(:a_facet) do
    double(
      OptionSelectFacet,
      key: 'case-type',
      selected_values: [
        {
          'value' => 'ca98-and-civil-cartels',
          'label' => 'CA98 and civil cartels'
        },
        {
          'value' => 'mergers',
          'label' => 'Mergers'
        },
      ],
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
      sentence_fragment: {
        'key' => 'case-type',
        'type' => 'text',
        'preposition' => 'Of Type',
        'values' => [
          {
            'label' => 'CA98 and civil cartels',
          },
          {
            'label' => 'Mergers',
          },
        ],
        'word_connectors' => { words_connector: 'or' }
      },
      has_filters?: true,
      labels: %W(ca98-and-civil-cartels mergers),
      value: %W(ca98-and-civil-cartels mergers)
    )
  end

  let(:b_facet) do
    double(
      OptionSelectFacet,
      key: 'personal-data',
      selected_values: [
          {
              'value' => 'personal-digital-data',
              'label' => 'personal-digital-data'
          },
          {
              'value' => 'personal-digital-data-private',
              'label' => 'personal-digital-data-private'
          },
      ],
      allowed_values: [
          {
              'value' => 'personal-digital-data',
              'label' => 'personal-digital-data'
          },
          {
              'value' => 'personal-digital-data-private',
              'label' => 'personal-digital-data-private'
          },
      ],
      sentence_fragment: {
          'key' => 'personal-data',
          'type' => 'text',
          'preposition' => 'Of Type',
          'values' => [
              {
                  'label' => 'personal-digital-data',
              },
              {
                  'label' => 'personal-digital-data-private',
              },
          ],
          'word_connectors' => { words_connector: 'or' }
      },
      has_filters?: true,
      labels: %W(personal-digital-data personal-digital-data-private),
      value: %W(personal-digital-data personal-digital-data-private)
    )
  end

  let(:results) do
    ResultSet.new(
      (1..total).map { document },
      total,
    )
  end

  let(:document) do
    double(
      Document,
      title: 'Investigation into the distribution of road fuels in parts of Scotland',
      path: 'slug-1',
      metadata: [
        { id: 'case-state', name: 'Case state', value: 'Open', type: 'text', labels: %W(open) },
        { id: 'opened-date', name: 'Opened date', value: '2006-7-14', type: 'date' },
        { id: 'case-type', name: 'Case type', value: 'CA98 and civil cartels', type: 'text', labels: %W(ca98-and-civil-cartels) },
        { id: 'personal-data', name: 'personal-data', value: 'personal-digital-data', type: 'text', labels: %W(personal-digital-data) },
      ],
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
      promoted: false,
      promoted_summary: nil,
      show_metadata: false,
      es_score: nil
    )
  end

  let(:keywords) { '' }
  let(:document_noun) { 'case' }
  let(:total) { 20 }

  let(:a_facet_collection) {
    double(FacetCollection, filters: [a_facet, primary_facet])
  }

  let(:primary_facet) do
    double(
      OptionSelectFacet,
      key: 'sector_business_area',
      allowed_values: [
        { 'value' => 'aerospace', 'label' => 'Aerospace' },
        { 'value' => 'agriculture', 'label' => 'Agriculture' },
      ],
      value: %W(aerospace agriculture),
      labels: %W(aerospace agriculture),
    )
  end

  describe '#to_hash' do
    before(:each) do
      allow(presenter).to receive(:selected_filter_descriptions)
      allow(presenter).to receive(:any_filters_applied?).and_return(true)
      allow(view_context).to receive(:render)
      allow(presenter).to receive(:grouped_display?).and_return(true)
      allow(presenter).to receive(:grouped_documents).and_return(key: 'value')
    end

    it 'returns an appropriate hash' do
      expect(presenter.to_hash[:display_grouped_results]).to be true
      expect(presenter.to_hash[:grouped_documents].present?).to be_truthy
    end
  end

  describe "#grouped_documents" do
    let(:tagging_metadata) {
      [{
        id: 'sector_business_area',
        name: 'Business area',
        value: 'Aerospace',
        type: 'text',
        labels: %W(aerospace)
      }]
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
        promoted: false,
        promoted_summary: nil,
        show_metadata: false,
        es_score: nil
      )
    }

    let(:primary_tagged_result) {
      SearchResultPresenter.new(tagged_document).to_hash
    }

    let(:document_result) { SearchResultPresenter.new(document).to_hash }

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
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)

        expect(subject.grouped_documents).to eq([{
          facet_name: 'All businesses',
          facet_key: 'all_businesses',
          documents: subject.documents
        }])
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
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)
        allow(a_facet_collection).to receive(:map).and_return([[a_facet.allowed_values], [primary_facet.allowed_values]])

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

    context "when primary and other facets have been selected" do
      let(:filter_params) {
        {
            order: 'topic',
            sector_business_area: %W(aerospace),
            'case-type': %W(ca98-and-civil-cartels),
            'personal-data': %W(personal-digital-data)
        }
      }

      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "orders the groups by facets in the other facets" do
        allow(finder).to receive(:filters).and_return([primary_facet, a_facet, b_facet])
        allow(a_facet_collection).to receive(:find)
        allow(a_facet_collection).to receive(:map).and_return([[a_facet.allowed_values], [b_facet.allowed_values], [primary_facet.allowed_values]])

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
              facet_name: 'personal-data',
              facet_key: 'personal-data',
              documents: [{ document: document_result, document_index: 1 }]
          }
        ])
      end
    end

    context "when other facets have been selected" do
      let(:filter_params) {
        {
          order: 'topic',
          'case-type': %W(ca98-and-civil-cartels),
          'personal-data': %W(digital-services)
        }
      }

      let(:results) { ResultSet.new([document, tagged_document], total) }

      it "groups the relevant documents in the other facets" do
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)

        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Case type',
            facet_key: 'case-type',
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
        allow(a_facet_collection).to receive(:find).and_return(primary_facet)
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])

        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'All businesses',
            facet_key: 'all_businesses',
            documents: [{ document: primary_tagged_result, document_index: 1 }]
          }
        ])
      end
    end

    context "when no filters have been selected" do
      let(:filter_params) { { order: 'topic' } }
      let(:results) { ResultSet.new([document], total) }

      it "groups all documents in the default group" do
        allow(finder).to receive(:filters).and_return([])
        allow(a_facet_collection).to receive(:find)

        expect(subject.grouped_documents).to eq([{
          facet_name: 'All businesses',
          facet_key: 'all_businesses',
          documents: subject.documents
        }])
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
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)
        allow(a_facet_collection).to receive(:map).and_return([[a_facet.allowed_values], [primary_facet.allowed_values]])

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
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)

        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'Case type',
            facet_key: 'case-type',
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
        allow(a_facet_collection).to receive(:find).and_return(primary_facet)
        allow(finder).to receive(:filters).and_return([a_facet, primary_facet])

        expect(subject.grouped_documents).to eq([
          {
            facet_name: 'All businesses',
            facet_key: 'all_businesses',
            documents: [{ document: primary_tagged_result, document_index: 1 }]
          }
        ])
      end
    end
  end

  describe "#grouped_display?" do
    context "a finder does not sort by topic" do
      let(:filter_params) { {} }
      before { allow(finder).to receive(:default_sort_option) }
      it "is false" do
        allow(finder).to receive(:sort).and_return([])

        expect(subject.grouped_display?).to be false
      end
    end

    context "a finder sorts by topic" do
      let(:topic_sort_option) { { 'name' => 'Topic', 'key' => 'topic' } }
      before do
        allow(finder).to receive(:default_sort_option).and_return(topic_sort_option)
        allow(finder).to receive(:sort).and_return([topic_sort_option])
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
      before { allow(finder).to receive(:default_sort_option) }
      it "is false" do
        allow(finder).to receive(:sort).and_return([])

        expect(subject.grouped_display?).to be false
      end
    end

    context "a finder sorts by topic" do
      let(:topic_sort_option) { { 'name' => 'Topic', 'key' => 'topic' } }
      before do
        allow(finder).to receive(:default_sort_option).and_return(topic_sort_option)
        allow(finder).to receive(:sort).and_return([topic_sort_option])
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
end
