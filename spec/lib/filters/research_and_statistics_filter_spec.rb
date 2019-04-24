require "spec_helper"

describe Filters::ResearchAndStatisticsFilter do
  subject(:filter) {
    Filters::ResearchAndStatisticsFilter.new(facet, params)
  }

  let(:facet) { { 'key' => 'content_store_document_type' } }

  describe '#query_hash' do
    context 'empty parameter' do
      let(:params) { nil }
      it 'returns the default query hash' do
        expect(filter.query_hash).to eq('content_store_document_type' => %w(statistics national_statistics statistical_data_set official_statistics))
      end
    end
    context 'invalid parameter' do
      let(:params) { "I'm not valid" }
      it 'returns the default query hash' do
        expect(filter.query_hash).to eq('content_store_document_type' => %w(statistics national_statistics statistical_data_set official_statistics))
      end
    end
    context 'valid parameter' do
      let(:params) { "upcoming_statistics" }
      it 'returns the default query hash' do
        Timecop.freeze(Time.local("2019-01-01"))
        expect(filter.query_hash).to eq('release_timestamp' => "from:2019-01-01",
                                         'format' => %w(statistics_announcement))
      end
    end
  end
end
