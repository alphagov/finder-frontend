require "spec_helper"

RSpec.describe Registries::RolesRegistry do
  let(:slug) { "prime-minister" }
  let(:search_api_v1_params) do
    {
      count: 0,
      facet_roles: "1500,examples:0,order:value.title",
    }
  end
  let(:search_api_v1_url) { "#{Plek.find('search-api')}/search.json?#{search_api_v1_params.to_query}" }

  describe "when search_api_v1 is available" do
    before do
      stub_request(:get, search_api_v1_url).to_return(body: search_api_v1_results)
      clear_cache
    end

    it "fetches role information by slug" do
      role = described_class.new[slug]
      expect(role).to eq(
        "title" => "Prime Minister",
        "slug" => slug,
      )
    end

    it "returns all roles associated with documents ascending by name" do
      roles = described_class.new.values

      expect(roles.length).to be(2)
      expect(roles.keys).to eql(%w[prime-minister chief-mouser])
    end
  end

  describe "there is no slug or title" do
    it "removes those results" do
      stub_request(:get, search_api_v1_url).to_return(
        body: {
          "facets": {
            "roles": {
              "options": [{ "value": {} }],
            },
          },
        }.to_json,
      )
      clear_cache
      expect(described_class.new.values).to be_empty
    end
  end

  describe "when search_api_v1 is unavailable" do
    before do
      search_api_v1_is_unavailable
      clear_cache
    end

    it "returns an (uncached) empty hash" do
      role = described_class.new[slug]
      expect(role).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def search_api_v1_is_unavailable
    stub_request(:get, search_api_v1_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end

  def search_api_v1_results
    %({
      "results": [],
      "total": 394075,
      "start": 0,
      "facets": {
        "roles": {
          "options": [{
            "value": {
              "title": "Prime Minister",
              "slug": "prime-minister",
              "_id": "a field that we're not using"
            },
            "documents": 5
          },
          {
            "value": {
              "title": "Chief Mouser",
              "slug": "chief-mouser",
              "_id": "/government/minister/chief-mouser"
            },
            "documents": 6
          }]
        }
      },
      "suggested_queries": []
    })
  end
end
