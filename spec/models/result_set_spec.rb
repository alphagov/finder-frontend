require 'spec_helper'

describe ResultSet do
  include ApiHelper

  describe ".get" do
    let(:finder_slug) { 'finder-slug' }
    let(:params) { { some_facet: 'a-facet-value' } }
    before { mock_api.stub(:get_documents).with(finder_slug, params).and_return(:result_set_hash) }

    subject { ResultSet.get(finder_slug, params) }

    it "should get a result set hash from the api and build a result set with it" do
      ResultSetParser.stub(:parse).with(:result_set_hash).and_return(:a_built_result_set)
      subject.should == :a_built_result_set
    end
  end

  describe "#count" do
    subject { ResultSet.new(documents: [:a_document_instance, :another_document_instance]) }

    specify { subject.count.should == 2 }
  end
end
