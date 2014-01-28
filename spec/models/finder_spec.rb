require 'spec_helper'

describe Finder do
  let(:slug) { "finder-slug" }
  let(:api) { FinderApi.new(slug) }

  describe ".build" do
    subject { Finder.build(api: api, facet_values: facet_values) }
    let(:schema) { {
      'name' => 'Finder name',
      'facets' => :the_facets_schema
    } }
    let(:facet_values) { :some_facet_values }

    before do
      api.stub(:get_schema).and_return(schema)
    end

    specify { subject.name.should == 'Finder name' }
    specify { subject.api.should == api }

    describe "building a facet collection" do
      before do
        FacetCollection.should_receive(:new).with(
          facets_schema: :the_facets_schema,
          facet_values: :some_facet_values
        ).and_return(:a_facet_collection)
      end

      specify { subject.facets.should == :a_facet_collection }
    end
  end

  describe '#results' do
    let(:facet_params) { :some_facet_values }
    let(:facet_collection) { OpenStruct.new(to_params: facet_params) }
    subject { Finder.new(api: api, facets: facet_collection) }

    before do
      ResultSet.stub(:get).with(api, :some_facet_values).and_return(:a_result_set)
    end

    specify { subject.results.should == :a_result_set }
  end
end
