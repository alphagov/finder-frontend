require 'spec_helper'

describe ResultSetParser do
  context "with a result set hash with some documents" do
    let(:results) {
      [
        :a_document_hash,
        :another_document_hash
      ]
    }
    let(:total) { 2 }

    let(:finder) { double(:finder) }

    subject { ResultSetParser.parse(results, total, finder) }

    before do
      Document.stub(:new).with(:a_document_hash, finder).and_return(:a_document_instance)
      Document.stub(:new).with(:another_document_hash, finder).and_return(:another_document_instance)
    end

    specify { subject.documents.should == [:a_document_instance, :another_document_instance] }
  end
end
