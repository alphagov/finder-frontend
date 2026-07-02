require "spec_helper"

RSpec.describe Registries::OrganisationsRegistry do
  include RegistrySpecHelper

  let(:slug) { "ministry-of-magic" }
  let(:search_api_v1_params) do
    {
      "count" => 1500,
      "fields" => %w[slug title acronym content_id],
      "filter_format" => "organisation",
      "order" => "title",
    }
  end
  let(:search_api_v1_url) { "#{Plek.find('search-api')}/search.json?#{search_api_v1_params.to_query}" }

  describe "when search_api_v1 is available" do
    before do
      stub_organisations_registry_request
      clear_cache
    end

    it "fetches organisation information by slug" do
      organisation = described_class.new[slug]
      expect(organisation).to eq(
        "title" => "Ministry of Magic",
        "acronym" => "MOM",
        "slug" => slug,
        "content_id" => "content_id_for_ministry-of-magic",
      )
    end

    it "returns organisations sorted by title with closed orgs at the end" do
      organisations = described_class.new.values

      expect(organisations.length).to be(4)
      expect(organisations.keys).to eql(%w[department-of-mysteries gringots ministry-of-magic death-eaters])
    end
  end

  describe "when search_api_v1 is unavailable" do
    before do
      search_api_v1_is_unavailable
      clear_cache
    end

    it "returns an (uncached) empty hash" do
      organisation = described_class.new[slug]
      expect(organisation).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def search_api_v1_is_unavailable
    stub_request(:get, search_api_v1_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end
end
