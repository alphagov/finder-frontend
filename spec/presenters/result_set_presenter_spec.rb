require 'spec_helper'

RSpec.describe ResultSetPresenter do

  subject(:presenter) { ResultSetPresenter.new(finder, params)}

  let(:params) {{"keywords"=>"", "case_type"=>["ca98-and-civil-cartels"], "slug"=>"cma-cases"}}

  let(:finder) do
    OpenStruct.new({
      results: result_set,
      document_noun: document_noun,
      facets: facets
    })
  end

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


  let(:facets) do
    OpenStruct.new(selected_facets_hash: selected_facets_hash)
  end

  let(:selected_facets_hash) do
    [
      {
        key:'',
        preposition: 'of type',
        selected_values: [
          { label: 'CA98 and civil cartels' },
          { label: 'Mergers' },
        ]
      },{
        key:'',
        preposition: 'about',
        selected_values: [
          { label: 'Farming' },
          { label: 'Chemicals' },
        ]
      }
    ]
  end
  describe '#to_hash' do
    it 'should return an appropriate hash' do
      presenter.to_hash[:count].should == count

      # We're testing the contents of these further down so for now just check they're there.
      presenter.to_hash[:pluralised_document_noun].present?.should == true
      presenter.to_hash[:applied_filters].present?.should == true
      presenter.to_hash[:documents].present?.should == true
    end

    it 'should call pluralize on the document noun with the results_count' do
      allow(document_noun).to receive(:pluralize).and_call_original
      presenter.to_hash
      document_noun.should have_received(:pluralize).with(count)
    end

    it 'should call describe_filters_in_sentence with selected_facets_hash' do
      allow(presenter).to receive(:describe_filters_in_sentence).and_call_original
      presenter.to_hash
      presenter.should have_received(:describe_filters_in_sentence).with selected_facets_hash
    end

    it 'should call documents' do
      allow(presenter).to receive(:documents).and_call_original
      presenter.to_hash
      presenter.should have_received(:documents).with
    end
  end

  describe '#describe_filters_in_sentence' do
    it 'should call facet_values_sentence for all selected_values in a facet' do
      allow(presenter).to receive(:facet_values_sentence).and_call_original
      presenter.describe_filters_in_sentence(selected_facets_hash)
      facets.each do | facet |
        presenter.should have_received(:facet_values_sentence).with facet
      end
    end

    it 'should include prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence(selected_facets_hash)
      facets.each do | facet |
        sentence.include?(facet[:preposition]).should == true
      end
    end

  end

  describe '#facet_values_sentence' do
    it 'should return a string with all the facets passed to it in strong tags' do
      facets.each do | facet |
        sentence = presenter.facet_values_sentence(facet)
        facet[:selected_values].each do |value|
          sentence.include?("<strong>#{value[:label]}</strong>").should == true
        end
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
