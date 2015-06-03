require 'spec_helper'

describe ResultSetParser do

  let(:finder) { double(:finder) }
  subject { ResultSetParser.new(finder) }

  context "with a result set hash with some documents" do
    let(:results) {
      [
        :a_document_hash,
        :another_document_hash
      ]
    }
    let(:response) {
      {
        total: 2,
        results: results,
        facets: {}
      }.with_indifferent_access
    }

    before do
      Document.stub(:new).with(:a_document_hash, finder).and_return(:a_document_instance)
      Document.stub(:new).with(:another_document_hash, finder).and_return(:another_document_instance)
    end

    specify {
      subject.parse(response).documents.should == [:a_document_instance, :another_document_instance]
    }
  end
end
