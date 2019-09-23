require "spec_helper"

RSpec.describe Registries::PeopleRegistry do
  let(:slug) { "cornelius-fudge" }
  let(:rummager_params) {
    {
      count: 0,
      facet_people: "1500,examples:0,order:value.title",
    }
  }
  let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_request(:get, rummager_url).to_return(body: rummager_results)
      clear_cache
    end

    it "will fetch person information by slug" do
      person = described_class.new[slug]
      expect(person).to eq(
        "title" => "Cornelius Fudge",
        "slug" => slug,
      )
    end

    it "will return all people associated with documents ascending by name" do
      people = described_class.new.values

      expect(people.length).to eql(2)
      expect(people.keys).to eql(%w(cornelius-fudge rufus-scrimgeour))
    end
  end

  describe "there is no slug or title" do
    it "will remove those results" do
      stub_request(:get, rummager_url).to_return(
        body: {
          "facets": {
            "people": {
              "options": [{ "value": {} }],
            },
          },
        }.to_json,
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
      person = described_class.new[slug]
      expect(person).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def rummager_is_unavailable
    stub_request(:get, rummager_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end

  def rummager_results
    %|{
      "results": [],
      "total": 394075,
      "start": 0,
      "facets": {
        "people": {
          "options": [{
            "value": {
              "title": "Cornelius Fudge",
              "slug": "cornelius-fudge",
              "_id": "a field that we're not using"
            },
            "documents": 5
          },
          {
            "value": {
              "title": "Rufus Scrimgeour",
              "slug": "rufus-scrimgeour",
              "_id": "/government/people/companies-house"
            },
            "documents": 6
          }]
        }
      },
      "suggested_queries": []
    }|
  end
end
