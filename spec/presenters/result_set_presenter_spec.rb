require 'spec_helper'

RSpec.describe ResultSetPresenter do

  subject(:presenter) { ResultSetPresenter.new(finder, params)}

  let(:params) {{}}

  let(:finder) do
    OpenStruct.new({
      results: result_set,
      document_noun: document_noun,
      facets: facets,
      keywords: keywords,
    })
  end

  let(:keywords){ '' }
  let(:document_noun){ 'case' }
  let(:count) { 2 }
  let(:facets) {[ :facet_1, :facet_2 ]}

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
      subject.stub(:describe_filters_in_sentence).and_return("a sentence summarising the selected filters")
      subject.stub(:documents).and_return({ key: 'value' })
      subject.stub(:any_filters_applied?).and_return(true)
    end

    it 'should return an appropriate hash' do
      subject.to_hash[:count].should == count
      subject.to_hash[:pluralised_document_noun].present?.should == true
      subject.to_hash[:documents].present?.should == true
      subject.to_hash[:applied_filters].present?.should == true
      subject.to_hash[:any_filters_applied].present?.should == true
    end

    it 'should call pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize)
      presenter.to_hash
      document_noun.should have_received(:pluralize).with(count)
    end

    it 'should call describe_filters_in_sentence' do
      allow(presenter).to receive(:describe_filters_in_sentence)
      presenter.to_hash
      presenter.should have_received(:describe_filters_in_sentence)
    end

    it 'should call documents' do
      allow(presenter).to receive(:documents)
      presenter.to_hash
      presenter.should have_received(:documents)
    end
  end

  describe '#describe_filters_in_sentence' do

    let(:facets) do
       OpenStruct.new(with_selected_values: [ a_facet, another_facet ])
     end

     let(:a_facet) do
       OpenStruct.new(
         key:'key_1',
         preposition: 'of type',
         selected_values:
           [
             OpenStruct.new({ value: 'CA98 and civil cartels', label: '   ' }),
             OpenStruct.new({ value: 'Mergers', label: '   '  }),
           ]
       )
     end

     let(:another_facet) do
       OpenStruct.new(
         key:'key_2',
         preposition: 'about',
         selected_values:
           [
             OpenStruct.new({ value: 'Farming', label: '   '  }),
             OpenStruct.new({ value: 'Chemicals', label: '   '  }),
           ]
       )
     end

    before(:each) do
      subject.stub(:facet_values_sentence)
      subject.stub(:link_params_without_facet_value)
    end

    it 'should call facet_values_sentence for all selected_values in a facet' do
      allow(presenter).to receive(:facet_values_sentence)
      presenter.describe_filters_in_sentence
      facets.each do | facet |
        presenter.should have_received(:facet_values_sentence).with facet
      end
    end

    it 'should include prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence
      facets.each do | facet |
        sentence.include?(facet[:preposition]).should == true
      end
    end

    context 'when keywords have been searched for' do
      let(:keywords) { "my search term" }

      it 'should include the keywords' do
        presenter.describe_filters_in_sentence.should include("my search term")
      end
    end
  end

  describe '#facet_values_sentence' do

    let(:a_facet) do
       OpenStruct.new(
         key:'key_1',
         preposition: 'of type',
         selected_values:
           [
             OpenStruct.new({ label: 'CA98 and civil cartels', value: 'ca98_and_civil_cartels' }),
             OpenStruct.new({ label: 'Mergers', value: 'mergers'}),
           ]
       )
     end

    before(:each) do
      subject.stub(:link_params_without_facet_value).and_return({})
    end

    it 'should return a string with all the facets passed to it in strong tags' do
      subject.stub(:link_params_without_facet_value).and_return({param_1: 'one'})

      sentence = subject.facet_values_sentence(a_facet)
      a_facet.selected_values.each do | value |
        sentence.include?("<strong>#{value.label}").should == true
        sentence.include?(subject.link_params_without_facet_value.to_query).should == true
      end
    end

    it 'should call link_params_without_facet_value for each option in a facet' do
      subject.facet_values_sentence(a_facet)
      a_facet.selected_values.each do | value |
        presenter.should have_received(:link_params_without_facet_value).with(a_facet.key, value.value)
      end
    end
  end

  describe '#link_params_without_facet_value' do
    let(:params){ { "first_key" => ["one", "two"], "second_key" => "three" } }
    it "should remove a string value" do
      subject.link_params_without_facet_value('second_key', 'three').should == { "first_key" => ["one", "two"] }
    end

    it "should remove a array value" do
      subject.link_params_without_facet_value('first_key', 'two').should == { "first_key" => ["one"], "second_key" => "three" }
    end

    context 'has an array of one' do
    let(:params){ { "first_key" => ["one"], "second_key" => "three" } }
      it "should remove an array of one item" do
        subject.link_params_without_facet_value('first_key', 'one').should == { "second_key" => "three" }
      end
    end
  end

  describe '#documents' do
    context "has one document" do
      let(:result_set) do
        OpenStruct.new({ count: count, documents: [ document ] })
      end
      it 'should create a new search_result_presenter hash for each result' do
        search_result_objects = subject.documents
        search_result_objects.count.should == 1
        search_result_objects.first.is_a?(Hash).should == true
      end
    end

    context "has 3 documents" do
      let(:result_set) do
        OpenStruct.new({ count: count, documents: [ document, document, document ] })
      end
      it 'should create a new document for each result' do
        search_result_objects = subject.documents
        search_result_objects.count.should == 3
      end
    end
  end
end
