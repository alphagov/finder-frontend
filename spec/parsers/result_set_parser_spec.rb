require 'spec_helper'

describe ResultSetParser do
  context "with a result set hash with some documents" do
    let(:results) { %i[a_document_hash another_document_hash] }
    let(:total) { 2 }

    subject { ResultSetParser.parse(results, total) }

    before do
      allow(Document).to receive(:new).with(:a_document_hash, 1).and_return(:a_document_instance)
      allow(Document).to receive(:new).with(:another_document_hash, 2).and_return(:another_document_instance)
    end

    specify { expect(subject.documents).to eql(%i[a_document_instance another_document_instance]) }
  end
end
