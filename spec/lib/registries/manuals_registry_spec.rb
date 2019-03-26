require 'spec_helper'

RSpec.describe Registries::ManualsRegistry do
  let(:slug) { '/guidance/care-and-use-of-a-nimbus-2000' }
  let(:rummager_params) {
    {
      filter_document_type: 'manual',
      fields: %w(title),
      count: 1500
    }
  }
  let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_request(:get, rummager_url).to_return(body: rummager_results)
      clear_cache
    end

    it "will fetch manual information by slug" do
      manual = described_class.new
      expect(manual[slug]).to eq(
        'title' => 'Care and use of a Nimbus 2000',
        'slug' => slug
      )
      expect(manual.values).to eq(
        slug => {
              'title' => 'Care and use of a Nimbus 2000',
              'slug' => slug
           }
       )
    end
  end

  describe 'there is no id or title' do
    it 'will remove those results' do
      stub_request(:get, rummager_url).to_return(
        body: {
          "results": [
            {
              'title' => '',
              'index' => 'govuk',
              'es_score' => nil,
              '_id' => ''
            }
          ]
        }
        .to_json
      )
      clear_cache
      expect(described_class.new.values).to be_empty
    end
  end

  describe "when rummager is unavailable" do
    before do
      rummager_is_unavailable
      clear_cache
    end

    it "will return an (uncached) empty hash" do
      manual = described_class.new[slug]
      expect(manual).to be_nil
      expect(Rails.cache.fetch(described_class::CACHE_KEY)).to be_nil
    end
  end

  def rummager_is_unavailable
    stub_request(:get, rummager_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class::CACHE_KEY)
  end

  def rummager_results
    %|{
      "results": [
        {
          "title": "Care and use of a Nimbus 2000",
          "index": "govuk",
          "es_score": "nil",
          "_id": "/guidance/care-and-use-of-a-nimbus-2000",
          "elasticsearch_type": "manual",
          "document_type": "manual"
        }
      ]
    }|
  end
end
