require "spec_helper"
require "gds_api/test_helpers/worldwide"

RSpec.describe Healthchecks::RegistriesCache do
  include GdsApi::TestHelpers::Worldwide
  include TaxonomySpecHelper
  include GdsApi::TestHelpers::ContentStore
  include GovukContentSchemaExamples
  include RegistrySpecHelper

  subject(:check) { described_class.new }

  before :each do
    Rails.cache.clear
  end

  after { Rails.cache.clear }

  context "All Registries have cached data" do
    before do
      worldwide_api_has_locations %w(hogwarts privet-drive diagon-alley)
      topic_taxonomy_has_taxons
      stub_people_registry_request
      stub_manuals_registry_request
      stub_organisations_registry_request

      Registries::BaseRegistries.new.refresh_cache
    end

    it "has an OK status" do
      expect(check.status).to eq :ok
      expect(check.message).to eq "OK"
    end
  end

  context "Registries caches are empty" do
    it "has an OK status" do
      expect(check.status).to eq :warning
      expect(check.message).to eq "The following registry caches are empty: world_locations, all_part_of_taxonomy_tree, part_of_taxonomy_tree, people, organisations, manual, full_topic_taxonomy."
    end
  end
end
