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
      facets: [a_facet, another_facet, a_date_facet],
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
      sentence_fragment: {
        'type' => 'text',
        'preposition' => 'of type',
        'values' => [
          {
            'label' => 'CA98 and civil cartels',
            'parameter_key' => 'key_1',
          },
          {
            'label' => 'Mergers',
            'parameter_key' => 'key_1',
          },
        ]
      }
    )
  end

  let(:another_facet) do
    double(
      SelectFacet,
      key: 'key_2',
      preposition: 'about',
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
        'type' => 'text',
        'preposition' => 'about',
        'values' => [
          {
            'label' => 'Farming',
            'parameter_key' => 'key_2',
          },
          {
            'label' => 'Chemicals',
            'parameter_key' => 'key_2',
          },
        ]
      }
    )
  end

  let(:a_date_facet) do
    double(
      SelectFacet,
      sentence_fragment: {
        'type' => "date",
        'preposition' => "closed between",
        'values' => [
          {
            'label' => "22 June 1990",
            'parameter_key' => "closed_date",
          },
          {
            'label' => "22 June 1994",
            'parameter_key' => "closed_date",
          }
        ]
      }
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
        { name: 'Case state', value: 'Open', type: 'text' },
        { name: 'Opened date', value: '2006-7-14', type: 'date' },
        { name: 'Case type', value: 'CA98 and civil cartels', type: 'text' },
      ],
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
    )
  end

  describe '#to_hash' do
    before(:each) do
      allow(presenter).to receive(:describe_filters_in_sentence).and_return("a sentence summarising the selected filters")
      allow(presenter).to receive(:documents).and_return(key: 'value')
      allow(presenter).to receive(:any_filters_applied?).and_return(true)
      allow(view_context).to receive(:render).and_return('<nav></nav>')
    end

    it 'returns an appropriate hash' do
      expect(presenter.to_hash[:total]).to eql(total)
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

    it 'calls pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize)
      presenter.to_hash
      expect(document_noun).to have_received(:pluralize).with(total)
    end

    it 'calls describe_filters_in_sentence' do
      allow(presenter).to receive(:describe_filters_in_sentence)
      presenter.to_hash
      expect(presenter).to have_received(:describe_filters_in_sentence)
    end

    it 'calls documents' do
      allow(presenter).to receive(:documents).and_return([double('document')])
      presenter.to_hash
      expect(presenter).to have_received(:documents).twice
    end
  end

  describe '#describe_filters_in_sentence' do
    before(:each) do
      allow(presenter).to receive(:link_without_facet_value)
      allow(finder).to receive(:filter_sentence_fragments).and_return([a_facet, another_facet, a_date_facet].flat_map(&:sentence_fragment).compact)
    end

    it 'calls selected_filter_descriptions' do
      allow(presenter).to receive(:selected_filter_descriptions)
      presenter.describe_filters_in_sentence
      expect(presenter).to have_received(:selected_filter_descriptions)
    end

    it 'includes prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence
      finder.filter_sentence_fragments.each do |fragment|
        expect(sentence).to include(fragment['preposition'])
      end
    end

    context 'when keywords have been searched for' do
      let(:keywords) { "my search term" }

      it 'includes the keywords' do
        expect(presenter.describe_filters_in_sentence).to include("my search term")
      end
    end

    context 'when XSS attack keywords have been searched for' do
      let(:keywords) { '<script>alert("hello")</script>' }

      it 'escapes keywords appropriately' do
        expect(presenter.describe_filters_in_sentence).to include('&lt;script&gt;alert')
      end
    end
  end

  describe '#facet_values_sentence' do
    before(:each) do
      allow(finder).to receive(:filter_sentence_fragments).and_return([a_facet, another_facet, a_date_facet].flat_map(&:sentence_fragment).compact)
    end

    let(:sentence) { presenter.selected_filter_descriptions }

    it 'returns a string with all the facets passed to it in strong tags' do
      finder.facets.flat_map { |f| f.sentence_fragment['values'] }.each do |value|
        expect(sentence).to include("<strong>#{value['label']}</strong>")
      end
    end

    it 'returns a string with the facet values joined correctly' do
      text_values = another_facet.selected_values
      expect(sentence).to include("<strong>#{text_values.first['label']}</strong> or <strong>#{text_values.last['label']}</strong>")

      date_fragment = a_date_facet.sentence_fragment
      expect(sentence).to include("<strong>#{date_fragment['values'].first['label']}</strong> and <strong>#{date_fragment['values'].last['label']}</strong>")
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
end
