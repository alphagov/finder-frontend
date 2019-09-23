require "securerandom"
require "spec_helper"
require "gds_api/test_helpers/worldwide"

RSpec.describe Registries::WorldLocationsRegistry do
  include GdsApi::TestHelpers::Worldwide

  let(:slug) { "privet-drive" }

  describe "when world locations api is available" do
    before do
      clear_cache
      worldwide_api_has_locations %w(hogwarts privet-drive diagon-alley)
    end

    after { clear_cache }

    subject(:registry) { described_class.new }

    it "will fetch an expanded world location by slug" do
      fetched_document = registry[slug]
      expect(fetched_document).to eq(
        "title" => "Privet Drive",
        "slug" => slug,
        "content_id" => "content_id_for_privet-drive",
      )
    end

    it "will return all world locations" do
      world_locations = registry.values

      expect(world_locations.length).to eql(3)
      expect(world_locations.keys).to eql(%w(hogwarts privet-drive diagon-alley))
    end
  end

  describe "when world locations API is unavailable" do
    it "will return an (uncached) empty array" do
      clear_cache
      world_locations_api_is_unavailable
      expect(described_class.new[slug]).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def world_locations_api_is_unavailable
    base_url = GdsApi::TestHelpers::Worldwide::WORLDWIDE_API_ENDPOINT
    stub_request(:get, "#{base_url}/api/world-locations").to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end
end
