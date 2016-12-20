require 'spec_helper'

RSpec.describe ResultSetPresenter do
  subject(:presenter) { ResultSetPresenter.new(finder, filter_params, view_context) }

  let(:finder) do
    OpenStruct.new(
      slug: "/a-finder",
      results: results,
      document_noun: document_noun,
      total: 20,
      facets: [a_facet, another_facet, a_date_facet],
      keywords: keywords,
      atom_url: "/a-finder.atom",
      default_documents_per_page: 10,
      values: {},
      pagination: pagination,
    )
  end

  let(:pagination) { double(:pagination, current_page: 1, total_pages: 2) }

  let(:filter_params) { double(:filter_params, {
    keywords: 'test'
  })}

  let(:view_context) { double(:view_context) }

  let(:a_facet) do
    OpenStruct.new(
      key: 'key_1',
      selected_values: [
        OpenStruct.new(
          value: 'ca98-and-civil-cartels',
          label: 'CA98 and civil cartels'
        ),
        OpenStruct.new(
          value: 'mergers',
          label: 'Mergers'
        ),
      ],
      sentence_fragment: [
        OpenStruct.new(
          type: 'text',
          preposition: 'of type',
          values: [
            OpenStruct.new(
              label: 'CA98 and civil cartels',
              parameter_key: 'key_1',
            ),
            OpenStruct.new(
              label: 'Mergers',
              parameter_key: 'key_1',
            ),
          ]
        )
      ],
    )
  end

  let(:another_facet) do
    OpenStruct.new(
      key: 'key_2',
      preposition: 'about',
      selected_values: [
        OpenStruct.new(
          value: 'farming',
          label: 'Farming'
        ),
        OpenStruct.new(
          value: 'chemicals',
          label: 'Chemicals'
        ),
      ],
      sentence_fragment: [
        OpenStruct.new(
          type: 'text',
          preposition: 'about',
          values: [
            OpenStruct.new(
              label: 'Farming',
              parameter_key: 'key_2',
            ),
            OpenStruct.new(
              label: 'Chemicals',
              parameter_key: 'key_2',
            ),
          ]
        )
      ],
    )
  end

  let(:a_date_facet) do
    OpenStruct.new(
      sentence_fragment: OpenStruct.new(
        type: "date",
        preposition: "closed between",
        values: [
          OpenStruct.new(
            label: "22 June 1990",
            parameter_key: "closed_date",
          ),
          OpenStruct.new(
            label: "22 June 1994",
            parameter_key: "closed_date",
          )
        ]
      )
    )
  end

  let(:keywords) { '' }
  let(:document_noun) { 'case' }
  let(:total) { 20 }

  let(:results) do
    OpenStruct.new(
      total: total,
      documents: (1..total).map { document }
    )
  end

  let(:document) do
    OpenStruct.new(
      title: 'Investigation into the distribution of road fuels in parts of Scotland',
      slug: 'slug-1',
      metadata:
        [
          { name: 'Case state', value: 'Open', type: 'text' },
          { name: 'Opened date', value: '2006-7-14', type: 'date' },
          { name: 'Case type', value: 'CA98 and civil cartels', type: 'text' },
        ]
    )
  end

  describe '#to_hash' do
    before(:each) do
      presenter.stub(:describe_filters_in_sentence).and_return("a sentence summarising the selected filters")
      presenter.stub(:documents).and_return(key: 'value')
      presenter.stub(:any_filters_applied?).and_return(true)
      view_context.stub(:render) { '<nav></nav>' }
    end

    it 'returns an appropriate hash' do
      presenter.to_hash[:total].should eql(total)
      presenter.to_hash[:pluralised_document_noun].present?.should be_true
      presenter.to_hash[:documents].present?.should be_true
      presenter.to_hash[:applied_filters].present?.should be_true
      presenter.to_hash[:any_filters_applied].present?.should be_true
      presenter.to_hash[:atom_url].present?.should be_true
      presenter.to_hash[:next_and_prev_links].present?.should be_true
    end

    it 'calls pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize)
      presenter.to_hash
      document_noun.should have_received(:pluralize).with(total)
    end

    it 'calls describe_filters_in_sentence' do
      allow(presenter).to receive(:describe_filters_in_sentence)
      presenter.to_hash
      presenter.should have_received(:describe_filters_in_sentence)
    end

    it 'calls documents' do
      allow(presenter).to receive(:documents)
      presenter.to_hash
      presenter.should have_received(:documents)
    end
  end

  describe '#describe_filters_in_sentence' do
    before(:each) do
      presenter.stub(:link_without_facet_value)
      finder.stub(:filter_sentence_fragments).and_return([a_facet, another_facet, a_date_facet].flat_map(&:sentence_fragment).compact)
    end

    it 'calls selected_filter_descriptions' do
      allow(presenter).to receive(:selected_filter_descriptions)
      presenter.describe_filters_in_sentence

      presenter.should have_received(:selected_filter_descriptions)
    end

    it 'includes prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence
      finder.filter_sentence_fragments.each do |fragment|
        sentence.include?(fragment[:preposition]).should be_true
      end
    end

    context 'when keywords have been searched for' do
      let(:keywords) { "my search term" }

      it 'includes the keywords' do
        presenter.describe_filters_in_sentence.should include("my search term")
      end
    end

    context 'when XSS attack keywords have been searched for' do
      let(:keywords) { '<script>alert("hello")</script>' }

      it 'escapes keywords appropriately' do
        presenter.describe_filters_in_sentence.should include('&lt;script&gt;alert')
      end
    end
  end

  describe '#facet_values_sentence' do
    before(:each) do
      finder.stub(:filter_sentence_fragments).and_return([a_facet, another_facet, a_date_facet].flat_map(&:sentence_fragment).compact)
    end

    let(:sentence) { presenter.selected_filter_descriptions }

    it 'returns a string with all the facets passed to it in strong tags' do
      finder.facets.flat_map(&:sentence_fragment).flat_map(&:values).flatten.each do |value|
        sentence.include?("<strong>#{value.label}").should be_true
      end
    end

    it 'returns a string with the facet values joined correctly' do
      text_values = another_facet.selected_values
      sentence.include?("<strong>#{text_values.first.label}</strong> or <strong>#{text_values.last.label}</strong>").should be_true

      date_fragment = a_date_facet.sentence_fragment
      sentence.include?("<strong>#{date_fragment.values.first.label}</strong> and <strong>#{date_fragment.values.last.label}</strong>").should be_true
    end
  end

  describe '#documents' do
    context "has one document" do
      let(:results) do
        OpenStruct.new(
          total: total,
          documents: [document]
        )
      end
      it 'creates a new search_result_presenter hash for each result' do
        search_result_objects = presenter.documents
        search_result_objects.count.should eql(1)
        search_result_objects.first.is_a?(Hash).should be_true
      end
    end

    context "has 3 documents" do
      let(:results) do
        OpenStruct.new(
          total: total,
          documents: [document, document, document]
        )
      end
      it 'creates a new document for each result' do
        search_result_objects = presenter.documents
        search_result_objects.count.should eql(3)
      end
    end
  end
end
