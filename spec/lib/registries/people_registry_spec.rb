require 'spec_helper'

RSpec.describe Registries::PeopleRegistry do
  let(:slug) { 'cornelius-fudge' }
  let(:default_rummager_params) {
    {
      "count" => 1500,
      "fields" => %w(slug title),
      "filter_format" => "person",
      "order" => 'title'
    }
  }
  let(:rummager_params) { default_rummager_params.merge("start" => 0) }
  let(:second_rummager_params) { default_rummager_params.merge("start" => 1) }
  let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }
  let(:second_rummager_url) { "#{Plek.current.find('search')}/search.json?#{second_rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_request(:get, rummager_url).to_return(body: rummager_results)
      stub_request(:get, second_rummager_url).to_return(body: { "results": [] }.to_json)
      clear_cache
    end

    it "will fetch person breadcrumb information by slug" do
      person = described_class.new[slug]
      expect(person).to eq(
        'title' => 'Cornelius Fudge',
        'slug' => slug
      )
    end

    it "will return all people ordered by title ascending" do
      people = described_class.new.values

      expect(people.length).to eql(2)
      expect(people.keys).to eql(%w(cornelius-fudge rufus-scrimgeour))
    end
  end

  describe "when rummager is unavailable" do
    before do
      rummager_is_unavailable
      clear_cache
    end

    it "will return an (uncached) empty hash" do
      person = described_class.new[slug]
      expect(person).to be_nil
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
          "title": "Cornelius Fudge",
          "slug": "cornelius-fudge",
          "_id": "a field that we're not using"
        },
        {
          "title": "Rufus Scrimgeour",
          "slug": "rufus-scrimgeour",
          "_id": "/government/people/companies-house"
        }
      ],
      "total": 2,
      "start": 0,
      "aggregates": {},
      "suggested_queries": []
    }|
  end
end
