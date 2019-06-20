# typed: false
require 'spec_helper'
require "gds_api/test_helpers/worldwide"
require "helpers/taxonomy_spec_helper"
require "helpers/registry_spec_helper"

RSpec.describe Registries::BaseRegistries do
  include GdsApi::TestHelpers::Worldwide
  include TaxonomySpecHelper
  include GdsApi::TestHelpers::ContentStore
  include GovukContentSchemaExamples
  include RegistrySpecHelper

  before do
    worldwide_api_has_locations %w(hogwarts privet-drive diagon-alley)
  end

  let(:subject) { described_class.new }
  let(:level_one_taxons) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "level_one_taxon.json")))
  }

  it "fetches all registries" do
    expect(subject.all).to have_key('manual')
    expect(subject.all).to have_key('full_topic_taxonomy')
    expect(subject.all).to have_key('world_locations')
    expect(subject.all).to have_key('part_of_taxonomy_tree')
    expect(subject.all).to have_key('organisations')
    expect(subject.all).to have_key('people')
  end

  it "provides world_locations registry" do
    expect(subject.all['world_locations']).to be_instance_of Registries::WorldLocationsRegistry
  end

  it "provides topic_taxonomy registry as part_of_taxonomy_tree" do
    expect(subject.all['part_of_taxonomy_tree']).to be_instance_of Registries::TopicTaxonomyRegistry
  end

  describe "#refresh_cache" do
    before do
      clear_cache
      stub_root_taxon(level_one_taxons)
      full_topic_taxonomy_has_taxons(level_one_taxons)
      stub_people_registry_request
      stub_manuals_registry_request
      stub_organisations_registry_request
    end
    after { clear_cache }

    it "refreshes the cache of all registries that implement refresh_cache" do
      registry_cache_keys.each { |cache_key|
        expect(Rails.cache.fetch(cache_key)).to be nil
      }

      described_class.new.refresh_cache

      registry_cache_keys.each { |cache_key|
        expect(Rails.cache.fetch(cache_key)).not_to be nil
      }
    end
  end

  def clear_cache
    Rails.cache.clear
  end

  def registry_cache_keys
    @registry_cache_keys ||= begin
      described_class.new.all.values.map(&:cache_key)
    end
  end
end
