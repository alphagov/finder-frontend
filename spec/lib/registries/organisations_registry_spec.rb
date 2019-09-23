require "spec_helper"

RSpec.describe Registries::OrganisationsRegistry do
  include RegistrySpecHelper

  let(:slug) { "ministry-of-magic" }
  let(:rummager_params) {
    {
      "count" => 1500,
      "fields" => %w(slug title acronym content_id),
      "filter_format" => "organisation",
      "order" => "title",
    }
  }
  let(:rummager_url) { "#{Plek.current.find('search')}/search.json?#{rummager_params.to_query}" }

  describe "when rummager is available" do
    before do
      stub_organisations_registry_request
      clear_cache
    end

    it "will fetch organisation information by slug" do
      organisation = described_class.new[slug]
      expect(organisation).to eq(
        "title" => "Ministry of Magic",
        "acronym" => "MOM",
        "slug" => slug,
        "content_id" => "content_id_for_ministry-of-magic",
      )
    end

    it "will return organisations sorted by title with closed orgs at the end" do
      organisations = described_class.new.values

      expect(organisations.length).to eql(4)
      expect(organisations.keys).to eql(%w(department-of-mysteries gringots ministry-of-magic death-eaters))
    end
  end

  describe "when rummager is unavailable" do
    before do
      rummager_is_unavailable
      clear_cache
    end

    it "will return an (uncached) empty hash" do
      organisation = described_class.new[slug]
      expect(organisation).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def rummager_is_unavailable
    stub_request(:get, rummager_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end
end
