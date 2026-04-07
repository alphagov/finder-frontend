require "spec_helper"
require "gds_api/test_helpers/worldwide"

RSpec.describe Healthcheck::RegistriesCacheCheck do
  include GdsApi::TestHelpers::Worldwide
  include TaxonomySpecHelper
  include GdsApi::TestHelpers::ContentStore
  include GovukContentSchemaExamples
  include RegistrySpecHelper

  subject(:check) { described_class.new }

  before do
    Rails.cache.clear
  end

  after { Rails.cache.clear }

  describe "#name" do
    it "returns 'registries_have_data'" do
      expect(check.name).to eq(:registries_have_data)
    end
  end

  describe "#enabled?" do
    it "returns true" do
      expect(check.enabled?).to be(true)
    end
  end

  context "All Registries have cached data" do
    before do
      stub_worldwide_api_has_locations %w[hogwarts privet-drive diagon-alley]
      topic_taxonomy_has_taxons
      stub_people_registry_request
      stub_roles_registry_request
      stub_manuals_registry_request
      stub_organisations_registry_request
      stub_topical_events_registry_request

      Registries::BaseRegistries.new.refresh_cache
    end

    it "has an OK status" do
      expect(check.status).to eq(GovukHealthcheck::OK)
    end

    it "does not set the message attribute" do
      check.status
      expect(check.message).to be_nil
    end
  end

  context "Registries caches are empty" do
    it "has a critical status" do
      expect(check.status).to eq(GovukHealthcheck::CRITICAL)
      expect(check.message).to eq "The following registry caches are empty: world_locations, all_part_of_taxonomy_tree, part_of_taxonomy_tree, people, roles, organisations, manual, full_topic_taxonomy, topical_events."
    end
  end
end
