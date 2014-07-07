require 'spec_helper'

RSpec.describe ResultSetPresenter do

  subject(:presenter) { ResultSetPresenter.new(finder, params)}

  let(:params) {{"keywords"=>"", "case_type"=>["ca98-and-civil-cartels"], "slug"=>"cma-cases"}}

  let(:finder) do
    OpenStruct.new({
      results: results,
      search_results_hash: results.search_results_hash,
      document_noun: document_noun,
      selected_facets_hash: facets
    })
  end

  let(:results) do
    OpenStruct.new({ count: count, search_results_hash:result_set })
  end

  let(:document_noun){ 'case' }
  let(:count) { 2 }

  let(:result_set) do
    [
      {
        title: 'Investigation into the distribution of road fuels in parts of Scotland',
        slug: 'slug-1',
        metadata:
          [
            {name: 'Case state', value: 'Open', type: '' },
            {name: 'Opened date', value: '2006-7-14', type: 'date' },
            {name: 'Case type', value: 'CA98 and civil cartels', type: '' },
          ],
      },
      {
        title: 'Heathcorp / Druginc merger inquiry',
        slug: 'slug-1',
        metadata:
          [
            { name: 'Case state', value: 'Closed', type: '' },
            { name: 'Opened date', value: '2005-12-30', type: '' },
            { name: 'Closed date', value: '2006-03-01', type: '' },
            { name: 'Outcome type', value: 'Mergers - phase 1 found not to qualify', type: '' },
            { name: 'Case type', value: 'Mergers', type: '' },
            { name: 'Market sector', value: 'Pharmaceuticals', type: '' },
          ]
      },
      {
        title: 'Investigation into the distribution of road fuels in parts of Scotland',
        slug: 'slug-1',
        metadata:
          [
            { name: 'Case state', value: 'Closed', type: '' },
            { name: 'Opened date', value: '2003-12-30', type: 'date' },
            { name: 'Closed date', value: '2004-03-01', type: 'date' },
            { name: 'Outcome type', value: 'CA98 - infringement Chapter I', type: '' },
            { name: 'Case type', value: 'CA98 and civil cartels', type: '' },
            { name: 'Market sector', value: 'Distribution and Service Industries', type: '' },
          ],
      }
    ]
  end

  let(:facets) do
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

    it 'should call describe_filters_in_sentence with facets' do
      allow(presenter).to receive(:describe_filters_in_sentence).and_call_original
      presenter.to_hash
      presenter.should have_received(:describe_filters_in_sentence).with facets
    end

    it 'should call package_metadata with document metadata' do
      allow(presenter).to receive(:format_result_metadata).and_call_original
      presenter.to_hash
      presenter.should have_received(:format_result_metadata).with result_set
    end
  end

  describe '#describe_filters_in_sentence' do
    it 'should call facet_values_sentence for all selected_values in a facet' do
      allow(presenter).to receive(:facet_values_sentence).and_call_original
      presenter.describe_filters_in_sentence(facets)
      facets.each do | facet |
        presenter.should have_received(:facet_values_sentence).with facet
      end
    end

    it 'should include prepositions for each facet' do
      sentence = presenter.describe_filters_in_sentence(facets)
      facets.each do | facet |
        sentence.include?(facet[:preposition]).should == true
      end
    end

    context 'with no facets' do
      let(:facets) {[]}
      it 'should return an empty string' do
        presenter.describe_filters_in_sentence(facets).should == ''
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

  describe '#format_result_metadata' do
    it 'should return an array' do
      presenter.format_result_metadata(result_set).is_a?(Array).should == true
    end

    context 'with no date metadata' do
      let(:result_set) do
        [{
          title: 'title',
          slug: 'test',
          metadata:[{ name: 'Case state', value: 'Closed'}],
        }]
      end

      it 'return name and value keys from the results' do
        presenter.format_result_metadata(result_set).should == result_set
      end
    end

    context 'with date metadata' do
      let(:result_set) do
        [{
          title: 'title',
          slug: 'test',
          metadata: [{ name: 'Date type', value: raw_date, type: type }],
        }]
      end
      let(:raw_date) { '2003-12-30' }
      let(:type) { 'date' }

      it 'should call format_date_if_date on each value' do
        allow(presenter).to receive(:format_date_if_date).and_call_original
        presenter.format_result_metadata(result_set)
        presenter.should have_received(:format_date_if_date).with raw_date, type
      end
    end

  end

  describe '#format_date_if_date' do
    let(:raw_date) { '2003-12-30' }
    let(:formatted_date) { '30 December 2003' }
    let(:a_date_type) { 'date'}
    let(:not_a_date_type) { 'not a date' }

    it 'should return a formatted date if type = date' do
      presenter.format_date_if_date(raw_date, a_date_type).should == formatted_date
    end

    it 'should return the unchanged value if type != date' do
      presenter.format_date_if_date(raw_date, not_a_date_type).should == raw_date
    end

  end

end
