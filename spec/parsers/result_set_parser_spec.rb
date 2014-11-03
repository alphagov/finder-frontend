require 'spec_helper'

describe ResultSetParser do
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
      }.with_indifferent_access
    }

    subject { ResultSetParser.parse(response) }

    before do
      DocumentParser.stub(:parse).with(:a_document_hash).and_return(:a_document_instance)
      DocumentParser.stub(:parse).with(:another_document_hash).and_return(:another_document_instance)
    end

    specify { subject.documents.should == [:a_document_instance, :another_document_instance] }
  end
end
