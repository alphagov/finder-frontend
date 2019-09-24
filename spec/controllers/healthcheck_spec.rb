require "spec_helper"
require "json"

describe "Healthcheck" do
  before do
    Rails.cache.clear
  end

  after do
    Rails.cache.clear
  end

  context "when everything is fine", type: :request do
    before do
      fill_registries
    end

    it "returns an OK status" do
      get "/healthcheck.json"
      expect(JSON.parse(response.body)).to eq(
        "checks" => {
          "registries_have_data" => {
            "message" => "OK",
            "status" => "ok",
          },
        },
        "status" => "ok",
      )
    end
  end

  context "when registries have no data", type: :request do
    before do
      Rails.cache.clear
    end

    it "returns a warning status" do
      get "/healthcheck.json"
      expect(JSON.parse(response.body)).to eq(
        "checks" => {
          "registries_have_data" => {
            "message" => "The following registry caches are empty: world_locations, all_part_of_taxonomy_tree, part_of_taxonomy_tree, people, organisations, manual, full_topic_taxonomy.",
            "status" => "warning",
          },
        },
        "status" => "warning",
      )
    end
  end

  def fill_registries
    cache_keys = Registries::BaseRegistries.new.all.values.map(&:cache_key)
    cache_keys.each { |key| Rails.cache.write(key, cached: "data") }
  end
end
