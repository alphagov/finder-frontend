require 'spec_helper'

describe ResultSetParser do
  context "with a result set hash with some documents" do
    let(:result_set_hash) { {
      'results' => [
        :a_document_hash,
        :another_document_hash
      ]
    } }

    subject { ResultSetParser.parse(result_set_hash) }

    before do
      DocumentParser.stub(:parse).with(:a_document_hash).and_return(:a_document_instance)
      DocumentParser.stub(:parse).with(:another_document_hash).and_return(:another_document_instance)
    end

    specify { subject.documents.should == [:a_document_instance, :another_document_instance] }
  end
end
