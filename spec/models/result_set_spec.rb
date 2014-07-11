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

  describe '#to_hash' do
    subject { ResultSet.new(documents: [a_document_instance, another_document_instance]) }
    let(:a_document_instance) { OpenStruct.new({title: title, slug: slug, metadata: metadata }) }
    let(:another_document_instance) { a_document_instance }

    let(:slug) {'slug-1'}
    let(:title) {'title 1'}
    let(:metadata) { 'metadata' }

    it 'should return search results as a hash' do
      subject.to_hash.is_a?(Array).should == true
      subject.to_hash[0][:title].should == title
      subject.to_hash[0][:slug].should == slug
      subject.to_hash[0][:metadata].should == metadata
    end
  end
end
