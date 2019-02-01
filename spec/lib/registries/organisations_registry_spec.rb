require 'spec_helper'

RSpec.describe Registries::OrganisationsRegistry do
  let(:slug) { 'ministry-of-magic' }
  let(:rummager_params) {
    {
      "count" => 1500,
      "fields" => %w(slug title),
      "filter_format" => "organisation"
    }
  }
  let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_request(:get, rummager_url).to_return(body: rummager_results)
      clear_cache
    end

    it "will fetch organisation breadcrumb information by slug" do
      organisation = described_class.new[slug]
      expect(organisation).to eq(
        'title' => 'Ministry of Magic',
        'slug' => slug
      )
    end
  end

  describe "when rummager is unavailable" do
    before do
      rummager_is_unavailable
      clear_cache
    end

    it "will return an (uncached) empty hash" do
      organisation = described_class.new[slug]
      expect(organisation).to be_nil
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
          "title": "Ministry of Magic",
          "slug": "ministry-of-magic",
          "_id": "a field that we're not using"
        },
        {
          "title": "Attorney General's Office",
          "slug": "attorney-generals-office",
          "_id": "/government/organisations/companies-house"
        }
      ],
      "total": 2,
      "start": 0,
      "aggregates": {},
      "suggested_queries": []
    }|
  end
end
