require "spec_helper"

RSpec.describe Registries::RolesRegistry do
  let(:slug) { "prime-minister" }
  let(:rummager_params) do
    {
      count: 0,
      facet_roles: "1500,examples:0,order:value.title",
    }
  end
  let(:rummager_url) { "#{Plek.find('search-api')}/search.json?#{rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_request(:get, rummager_url).to_return(body: rummager_results)
      clear_cache
    end

    it "will fetch role information by slug" do
      role = described_class.new[slug]
      expect(role).to eq(
        "title" => "Prime Minister",
        "slug" => slug,
      )
    end

    it "will return all roles associated with documents ascending by name" do
      roles = described_class.new.values

      expect(roles.length).to eql(2)
      expect(roles.keys).to eql(%w[prime-minister chief-mouser])
    end
  end

  describe "there is no slug or title" do
    it "will remove those results" do
      stub_request(:get, rummager_url).to_return(
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

  describe "when rummager is unavailable" do
    before do
      rummager_is_unavailable
      clear_cache
    end

    it "will return an (uncached) empty hash" do
      role = described_class.new[slug]
      expect(role).to be_nil
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
