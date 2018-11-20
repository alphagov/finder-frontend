require "securerandom"
require 'spec_helper'
require "gds_api/test_helpers/worldwide"

RSpec.describe Registries::WorldLocationsRegistry do
  include GdsApi::TestHelpers::Worldwide

  describe "when world locations api is available" do
    before do
      clear_cache
      worldwide_api_has_locations %w(hogwarts privet-drive diagon-alley)
    end

    after { clear_cache }

    subject(:registry) { described_class.new }

    let(:slug) { 'privet-drive' }

    it "will fetch an expanded world location by slug" do
      fetched_document = registry[slug]
      expect(fetched_document).to eq(
        'title' => 'Privet Drive',
        'slug' => slug
      )
    end

    it "will return all expanded world locations" do
      expect(registry.all).to contain_exactly(
        {
          "slug" => "hogwarts",
          "title" => "Hogwarts"
        },
        {
          "slug" => "privet-drive",
          "title" => "Privet Drive"
        },
         "slug" => "diagon-alley",
         "title" => "Diagon Alley"
      )
    end
  end

  describe "when world locations API is unavailable" do
    it "will return an (uncached) empty array" do
      clear_cache
      world_locations_api_is_unavailable
      expect(described_class.new.all).to eql([])
      expect(Rails.cache.fetch(described_class::CACHE_KEY)).to be_nil
    end
  end

  def world_locations_api_is_unavailable
    base_url = GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT
    stub_request(:get, "#{base_url}/api/world-locations").to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class::CACHE_KEY)
  end
end
