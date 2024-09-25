require "spec_helper"

describe ResultSetParser do
  context "with a result set hash with some documents" do
    subject { described_class.parse("results" => results, "start" => start, "total" => total) }

    let(:results) { %i[a_document_hash another_document_hash] }
    let(:total) { 2 }
    let(:start) { 1 }

    before do
      allow(Document).to receive(:new).with(:a_document_hash, 1).and_return(:a_document_instance)
      allow(Document).to receive(:new).with(:another_document_hash, 2).and_return(:another_document_instance)
    end

    specify { expect(subject.documents).to eql(%i[a_document_instance another_document_instance]) }
    specify { expect(subject.start).to eql(start) }
    specify { expect(subject.total).to eql(total) }
  end

  context "when an attribution token is returned" do
    subject do
      described_class.parse(
        "results" => results,
        "start" => start,
        "total" => total,
        "discovery_engine_attribution_token" => discovery_engine_attribution_token,
      )
    end

    let(:results) { %i[a_document_hash] }
    let(:total) { 1 }
    let(:start) { 1 }
    let(:discovery_engine_attribution_token) { "123ABC" }

    before do
      allow(Document).to receive(:new).with(:a_document_hash, 1).and_return(:a_document_instance)
    end

    specify { expect(subject.documents).to eql(%i[a_document_instance]) }
    specify { expect(subject.discovery_engine_attribution_token).to eql(discovery_engine_attribution_token) }
  end
end
