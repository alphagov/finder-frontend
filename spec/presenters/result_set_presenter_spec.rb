require 'spec_helper'

RSpec.describe ResultSetPresenter do
  subject(:presenter) { ResultSetPresenter.new(finder, filter_params, view_context) }

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
    )
  end

  let(:pagination) { { 'current_page' => 1, 'total_pages' => 2 } }

  let(:filter_params) { double(:filter_params, keywords: 'test') }

  let(:view_context) { double(:view_context) }

  let(:a_facet) do
    double(
      SelectFacet,
      key: 'key_1',
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
        'key' => 'key_1',
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
      value: ['ca98-and-civil-cartels', 'mergers']
    )
  end

  let(:a_facet_collection) do
    double(
      FacetCollection,
      filters: [a_facet, another_facet, a_date_facet]
    )
  end

  let(:another_facet) do
    double(
      SelectFacet,
      key: 'key_2',
      preposition: 'About',
      selected_values: [
        {
          'value' => 'farming',
          'label' => 'Farming'
        },
        {
          'value' => 'chemicals',
          'label' => 'Chemicals'
        },
      ],
      sentence_fragment: {
        'key' => 'key_2',
        'type' => 'text',
        'preposition' => 'About',
        'values' => [
          {
            'label' => 'Farming',
          },
          {
            'label' => 'Chemicals',
          },
        ],
        'word_connectors' => { words_connector: 'or' }
      },
      has_filters?: true,
      value: %w[farming chemicals],
      'word_connectors' => { words_connector: 'or' }
    )
  end

  let(:a_date_facet) do
    double(
      SelectFacet,
      'key' => 'closed_date',
      sentence_fragment: nil,
      has_filters?: false,
      'word_connectors' => { words_connector: 'or' }
    )
  end

  let(:keywords) { '' }
  let(:document_noun) { 'case' }
  let(:total) { 20 }

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
      ],
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
      promoted: false,
    )
  end

  describe '#to_hash' do
    before(:each) do
      allow(presenter).to receive(:selected_filter_descriptions).and_return("a sentence summarising the selected filters")
      allow(presenter).to receive(:documents).and_return(key: 'value')
      allow(presenter).to receive(:any_filters_applied?).and_return(true)
      allow(presenter).to receive(:grouped_display?).and_return(false)
      allow(view_context).to receive(:render).and_return('<nav></nav>')
    end

    it 'returns an appropriate hash' do
      expect(presenter.to_hash[:total]).to eql(total.to_s)
      expect(presenter.to_hash[:generic_description].present?).to be_truthy
      expect(presenter.to_hash[:pluralised_document_noun].present?).to be_truthy
      expect(presenter.to_hash[:documents].present?).to be_truthy
      expect(presenter.to_hash[:page_count].present?).to be_truthy
      expect(presenter.to_hash[:finder_name].present?).to be_truthy
      expect(presenter.to_hash[:applied_filters].present?).to be_truthy
      expect(presenter.to_hash[:any_filters_applied].present?).to be_truthy
      expect(presenter.to_hash[:atom_url].present?).to be_truthy
      expect(presenter.to_hash[:next_and_prev_links].present?).to be_truthy
    end

    # FIXME: Behaviour has changed with grouping results
    it 'calls pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize)
      presenter.to_hash
      expect(document_noun).to have_received(:pluralize).with(total)
    end

    it 'calls selected_filter_descriptions' do
      allow(presenter).to receive(:selected_filter_descriptions)
      presenter.to_hash
      expect(presenter).to have_received(:selected_filter_descriptions)
    end

    it 'calls documents' do
      allow(presenter).to receive(:documents).and_return([double('document')])
      presenter.to_hash
      expect(presenter).to have_received(:documents).twice
    end
  end

  describe '#selected_filter_descriptions' do
    before(:each) do
      allow(presenter).to receive(:link_without_facet_value)
      allow(finder).to receive(:filters).and_return([a_facet, another_facet, a_date_facet])
    end

    it 'includes prepositions for each facet' do
      applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
      prepositions = applied_filters.flat_map { |filter| filter[:preposition] }.reject { |preposition| preposition == "or" }

      finder.filters.reject { |filter| filter.sentence_fragment.nil? }.each do |fragment|
        expect(prepositions).to include(fragment.sentence_fragment['preposition'])
      end
    end

    context 'when keywords have been searched for' do
      let(:keywords) { "my search term" }

      it 'includes the keywords' do
        applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
        text_values = applied_filters.flat_map { |filter| filter[:text] }

        expect(text_values).to include("my", "search", "term")
      end
    end

    context 'when XSS attack keywords have been searched for' do
      let(:keywords) { '<script>alert("hello")</script>' }

      it 'escapes keywords appropriately' do
        applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
        text_values = applied_filters.flat_map { |filter| filter[:text] }

        expect(["script", "alert", "&quot;hello&quot;"].any? { |word| text_values.join(" ").include?(word) })
      end
    end
  end

  describe '#facet_values_sentence' do
    before(:each) do
      allow(finder).to receive(:filters).and_return([a_facet, another_facet, a_date_facet])
    end

    let(:applied_filters) { presenter.selected_filter_descriptions.flat_map { |filter| filter } }

    it 'returns an array of hashes that can be used to construct facet tags' do
      text_values = applied_filters.flat_map { |filter| filter[:text] }
      finder.facets.filters.flat_map { |filter| filter.sentence_fragment.nil? ? nil : filter.sentence_fragment['values'] }.compact.each do |value|
        expect(text_values).to include(value['label'])
      end
    end
  end

  describe '#documents' do
    context "has one document" do
      let(:results) do
        ResultSet.new(
          [document],
          total
        )
      end

      it 'creates a new search_result_presenter hash for each result' do
        search_result_objects = presenter.documents
        expect(search_result_objects.count).to eql(1)
        expect(search_result_objects.first).to be_a(Hash)
      end
    end

    context "has 3 documents" do
      let(:results) do
        ResultSet.new(
          [document, document, document],
          total
        )
      end

      it 'creates a new document for each result' do
        search_result_objects = presenter.documents
        expect(search_result_objects.count).to eql(3)
      end
    end
  end

  describe "#documents_by_facets" do
    let(:primary_facet) do
      double(
        SelectFacet,
        key: 'sector_business_area',
        allowed_values: [
          { 'value' => 'aerospace', 'label' => 'Aerospace' },
          { 'value' => 'agriculture', 'label' => 'Agriculture' },
        ],
        value: %W(aerospace agriculture),
        labels: %W(aerospace agriculture),
      )
    end

    let(:a_facet_collection) {
      double(FacetCollection, filters: [a_facet, another_facet, primary_facet])
    }

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
        expect(subject.documents_by_facets).to eq([])
      end
    end

    context "when no filters have been selected" do
      let(:filter_params) { { order: 'topic' } }
      let(:results) { ResultSet.new([document], total) }

      it "groups all documents in the default group" do
        allow(a_facet_collection).to receive(:find)
        expect(subject.documents_by_facets).to eq([{
          facet_name: 'All Businesses',
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

        allow(finder).to receive(:filters).and_return([a_facet, another_facet, primary_facet])
        allow(a_facet_collection).to receive(:find)
        allow(a_facet_collection).to receive(:map).and_return([[a_facet.allowed_values], [primary_facet.allowed_values]])

        expect(subject.documents_by_facets).to eq([
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
        allow(a_facet_collection).to receive(:find)
        expect(subject.documents_by_facets).to eq([
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
        allow(finder).to receive(:filters).and_return([a_facet, another_facet, primary_facet])

        expect(subject.documents_by_facets).to eq([
          {
            facet_name: 'All Businesses',
            facet_key: 'all_businesses',
            documents: [{ document: primary_tagged_result, document_index: 1 }]
          }
        ])
      end
    end
  end
end
