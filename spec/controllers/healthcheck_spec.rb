require 'spec_helper'
require 'json'

describe 'Healthcheck' do
  include ContentStoreServiceHelper

  before do
    Rails.cache.clear
  end

  after do
    Rails.cache.clear
  end

  context 'when everything is fine', type: :request do
    before do
      fill_registries
      search_api_has_finders
      content_items_are_already_cached
    end

    it "returns an OK status" do
      get '/healthcheck.json'
      expect(JSON.parse(response.body)).to eq(
        "checks" => {
          "registries_have_data" => {
            "message" => "OK",
            "status" => "ok",
          },
          "content_items_are_cached" => {
            "message" => "OK",
            "status" => "ok",
          }
        },
        "status" => "ok",
      )
    end
  end

  context 'when registries have no data', type: :request do
    before do
      Rails.cache.clear
      search_api_has_finders
    end

    it "returns a warning status" do
      get '/healthcheck.json'
      res = JSON.parse(response.body)
      expect(res["status"]).to eq("warning")
      expect(res['checks']['registries_have_data']['status']).to eq("warning")
      expect(res['checks']['content_items_are_cached']['status']).to eq("warning")
    end
  end

  def fill_registries
    cache_keys = Registries::BaseRegistries.new.all.values.map(&:cache_key)
    cache_keys.each { |key| Rails.cache.write(key, cached: "data") }
  end
end
