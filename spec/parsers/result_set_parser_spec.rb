require 'rails_helper'

describe ResultSetParser do
  context "with a result set hash with some documents" do
    let(:results) {
      [
        :a_document_hash,
        :another_document_hash
      ]
    }

    subject { ResultSetParser.parse(results) }

    before do
      DocumentParser.stub(:parse).with(:a_document_hash).and_return(:a_document_instance)
      DocumentParser.stub(:parse).with(:another_document_hash).and_return(:another_document_instance)
    end

    specify { subject.documents.should == [:a_document_instance, :another_document_instance] }
  end
end
