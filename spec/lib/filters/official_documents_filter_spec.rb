require "spec_helper"

describe Filters::OfficialDocumentsFilter do
  subject(:filter) {
    Filters::OfficialDocumentsFilter.new(facet, params_value)
  }

  let(:facet) { { 'key' => 'content_store_document_type' } }

  describe '#query_hash' do
    context 'empty parameter' do
      let(:params_value) { nil }
      it 'returns the default query hash' do
        expect(filter.query_hash).to eq('has_official_document' => true)
      end
    end
    context 'invalid parameter' do
      let(:params_value) { "I'm not valid" }
      it 'returns the default query hash' do
        expect(filter.query_hash).to eq('has_official_document' => true)
      end
    end
    context 'valid parameter' do
      let(:params_value) { "command_papers" }
      it 'returns documents which only have command papers' do
        expect(filter.query_hash).to eq('has_command_paper' => true, 'has_act_paper' => false)
      end
    end
  end
end
