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
      default_documents_per_page: 10,
      values: {},
      pagination: pagination,
      sort: [
        {
          "name" => "Most viewed",
          "key" => "-popularity"
        },
        {
          "name" => "Relevance",
          "key" => "-relevance"
        },
        {
          "name" => "Updated (newest)",
          "key" => "-public_timestamp",
          "default" => true
        }
      ],
      default_sort_option: {
        "name" => "Updated (newest)",
        "key" => "-public_timestamp",
      },
      filters: {}
    )
  end

  let(:pagination) { { 'current_page' => 1, 'total_pages' => 2 } }

  let(:filter_params) { { keywords: 'test' } }

  let(:view_context) { double(:view_context) }

  let(:a_facet) do
    double(
      OptionSelectFacet,
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
      labels: %W(ca98-and-civil-cartels mergers),
      value: %W(ca98-and-civil-cartels mergers),
      hide_facet_tag?: false
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
      OptionSelectFacet,
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
      'word_connectors' => { words_connector: 'or' },
      hide_facet_tag?: false
    )
  end

  let(:a_date_facet) do
    double(
      OptionSelectFacet,
      'key' => 'closed_date',
      sentence_fragment: nil,
      has_filters?: false,
      'word_connectors' => { words_connector: 'or' },
      hide_facet_tag?: false
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
      promoted_summary: nil,
      show_metadata: false,
      es_score: 0.005
    )
  end

  let(:a_facet_without_facet_tags) do
    double(
      RadioFacet,
      key: 'key_3',
      preposition: 'that are',
      allowed_values: [
      {
        'value' => 'statistics_published',
        'label' => 'Statistics (published)',
        'default' => true
      },
      {
        'value' => 'statistics_upcoming',
        'label' => 'Statistics (upcoming)'
      },
      {
        'value' => 'research',
        'label' => 'Research'
      },
    ],
      has_filters?: true,
      hide_facet_tag?: true,
      value: "something",
      sort: [
      {
        'value' => 'most-viewed',
        'name' => 'Most viewed'
      }
    ]
    )
  end

  describe '#to_hash' do
    before(:each) do
      allow(presenter).to receive(:selected_filter_descriptions).and_return("a sentence summarising the selected filters")
      allow(presenter).to receive(:documents).and_return(key: 'value')
      allow(presenter).to receive(:any_filters_applied?).and_return(true)
      allow(presenter).to receive(:grouped_display?).and_return(false)
      allow(view_context).to receive(:render).and_return('<nav></nav>')

      allow(finder).to receive(:atom_url).and_return("/finder.atom")
      allow(finder).to receive(:email_alert_signup_url).and_return("/email_signup")
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
  end

  describe '#signup_links' do
    context 'has both signup links' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("/finder.atom")
        allow(finder).to receive(:email_alert_signup_url).and_return("/email_signup")
      end

      it 'returns both signup links' do
        expect(presenter.signup_links).to eq(email_signup_link: "/email_signup", feed_link: "/finder.atom", margin_bottom: 3)
      end
    end

    context 'has just has the atom signup link' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("/finder.atom")
        allow(finder).to receive(:email_alert_signup_url).and_return("")
      end

      it 'returns just the atom link' do
        expect(presenter.signup_links).to eq(feed_link: "/finder.atom", margin_bottom: 3)
      end
    end
  end


  describe '#has_email_signup_link?' do
    context 'has one signup link' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("")
        allow(finder).to receive(:email_alert_signup_url).and_return("/email_signup")
      end

      it 'returns true' do
        expect(presenter.has_email_signup_link?).to eq(true)
      end
    end

    context 'has no links' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("")
        allow(finder).to receive(:email_alert_signup_url).and_return("")
      end

      it 'returns false' do
        expect(presenter.has_email_signup_link?).to eq(false)
      end
    end
  end
end
