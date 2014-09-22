require 'spec_helper'

RSpec.describe ResultSetPresenter do

  subject(:presenter) { ResultSetPresenter.new(finder, params)}

  let(:params) {{}}

  let(:finder) do
    OpenStruct.new({
      results: result_set,
      document_noun: document_noun,
      facets: [ a_facet, another_facet ],
      keywords: keywords,
    })
  end

  let(:a_facet) do
    OpenStruct.new(
      key:'key_1',
      selected_values:[
        OpenStruct.new({ value: 'ca98-and-civil-cartels', label: 'CA98 and civil cartels' }),
        OpenStruct.new({ value: 'mergers', label: 'Mergers' }),
      ],
      sentence_fragment: [
        OpenStruct.new(
          preposition: 'of type',
          values: [
            OpenStruct.new(
              label: 'CA98 and civil cartels',
              parameter_key: 'key_1',
              other_params: ['mergers'],
            ),
            OpenStruct.new(
              label: 'Mergers',
              parameter_key: 'key_1',
              other_params: ['ca98-and-civil-cartels'],
            ),
          ]
        )
      ],
    )
  end

  let(:another_facet) do
    OpenStruct.new(
      key:'key_2',
      preposition: 'about',
      selected_values: [
        OpenStruct.new({ value: 'farming', label: 'Farming' }),
        OpenStruct.new({ value: 'chemicals', label: 'Chemicals' }),
      ],
      sentence_fragment: [
        OpenStruct.new(
          preposition: 'about',
          values: [
            OpenStruct.new(
              label: 'Farming',
              parameter_key: 'key_2',
              other_params: ['chemicals'],
            ),
            OpenStruct.new(
              label: 'Chemicals',
              parameter_key: 'key_2',
              other_params: ['farming'],
            ),
          ]
        )
      ],
    )
  end

  let(:keywords){ '' }
  let(:document_noun){ 'case' }
  let(:count) { 2 }

  let(:result_set) do
    OpenStruct.new({ count: count, documents: [ document ] })
  end

  let(:document) do
    OpenStruct.new({
      title: 'Investigation into the distribution of road fuels in parts of Scotland',
      slug: 'slug-1',
      metadata:
        [
          { name: 'Case state', value: 'Open', type: 'text' },
          { name: 'Opened date', value: '2006-7-14', type: 'date' },
          { name: 'Case type', value: 'CA98 and civil cartels', type: 'text' },
        ]
      })
  end

  describe '#to_hash' do
    before(:each) do
      presenter.stub(:describe_filters_in_sentence).and_return("a sentence summarising the selected filters")
      presenter.stub(:documents).and_return({ key: 'value' })
      presenter.stub(:any_filters_applied?).and_return(true)
    end

    it 'returns an appropriate hash' do
      presenter.to_hash[:count].should == count
      presenter.to_hash[:pluralised_document_noun].present?.should == true
      presenter.to_hash[:documents].present?.should == true
      presenter.to_hash[:applied_filters].present?.should == true
      presenter.to_hash[:any_filters_applied].present?.should == true
    end

    it 'calls pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize)
      presenter.to_hash
      document_noun.should have_received(:pluralize).with(count)
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
      finder.stub(:facet_sentence_fragments).and_return( [a_facet, another_facet].flat_map { |f| f.sentence_fragment }.compact )
    end

    it 'calls selected_filter_descriptions' do
      allow(presenter).to receive(:selected_filter_descriptions)
      presenter.describe_filters_in_sentence

      presenter.should have_received(:selected_filter_descriptions)
    end

    it 'includes prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence
      finder.facet_sentence_fragments.each do | fragment |
        sentence.include?(fragment[:preposition]).should == true
      end
    end

    context 'when keywords have been searched for' do
      let(:keywords) { "my search term" }

      it 'includes the keywords' do
        presenter.describe_filters_in_sentence.should include("my search term")
      end
    end
  end

  describe '#facet_values_sentence' do

    before(:each) do
      presenter.stub(:link_params_without_facet_value).and_return({})
      finder.stub(:facet_sentence_fragments).and_return( [a_facet, another_facet].flat_map { |f| f.sentence_fragment }.compact )
    end

    let(:a_facet) do
      OpenStruct.new(
        sentence_fragment: OpenStruct.new(
          preposition: 'about',
          values: [
            OpenStruct.new(
              label: 'Farming',
              parameter_key: 'key_1',
              other_params: ['chemicals'],
            ),
            OpenStruct.new(
              label: 'Chemicals',
              parameter_key: 'key_1',
              other_params: ['farming'],
            ),
          ]
        )
      )
    end

    it 'returns a string with all the facets passed to it in strong tags' do
      presenter.stub(:link_params_without_facet_value).and_return({param_1: 'one'})

      sentence = presenter.selected_filter_descriptions
      a_facet.sentence_fragment.values.each do | value |
        sentence.include?("<strong>#{value.label}").should == true
        sentence.include?(presenter.link_params_without_facet_value.to_query).should == true
      end
    end

    it 'calls link_params_without_facet_value for each option in a facet' do
      presenter.selected_filter_descriptions
      a_facet.sentence_fragment.values.each do | value |
        presenter.should have_received(:link_params_without_facet_value).with(value.parameter_key, value.other_params)
      end
    end
  end

  describe '#link_params_without_facet_value' do
    let(:params){ { "first_key" => ["one", "two"], "second_key" => "three" } }
    it "removes an empty parameter" do
      presenter.link_params_without_facet_value("second_key", []).should == { "first_key" => ["one", "two"] }
    end

    it "removes a single value" do
      presenter.link_params_without_facet_value('first_key', ["two"]).should == { "first_key" => ["two"], "second_key" => "three" }
    end
  end

  describe '#documents' do
    context "has one document" do
      let(:result_set) do
        OpenStruct.new({ count: count, documents: [ document ] })
      end
      it 'creates a new search_result_presenter hash for each result' do
        search_result_objects = presenter.documents
        search_result_objects.count.should == 1
        search_result_objects.first.is_a?(Hash).should == true
      end
    end

    context "has 3 documents" do
      let(:result_set) do
        OpenStruct.new({ count: count, documents: [ document, document, document ] })
      end
      it 'creates a new document for each result' do
        search_result_objects = presenter.documents
        search_result_objects.count.should == 3
      end
    end
  end
end
