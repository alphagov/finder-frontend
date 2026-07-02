require "spec_helper"

RSpec.describe Registries::ManualsRegistry do
  let(:slug) { "/guidance/care-and-use-of-a-nimbus-2000" }
  let(:search_api_v1_params) do
    {
      filter_document_type: %w[hmrc_manual manual service_manual_homepage service_manual_guide],
      fields: %w[title],
      count: 1500,
    }
  end
  let(:search_api_v1_url) { "#{Plek.find('search-api')}/search.json?#{search_api_v1_params.to_query}" }

  describe "when search_api_v1 is available" do
    before do
      stub_request(:get, search_api_v1_url).to_return(body: search_api_v1_results)
      clear_cache
    end

    it "fetches manual information by slug" do
      manual = described_class.new
      expect(manual[slug]).to eq(
        "title" => "Care and use of a Nimbus 2000",
        "slug" => slug,
      )
      expect(manual.values).to eq(
        slug => {
          "title" => "Care and use of a Nimbus 2000",
          "slug" => slug,
        },
      )
    end

    it "fetches the correct types of document" do
      described_class.new[slug]
      assert_requested :get, search_api_v1_url
    end
  end

  describe "there is no id or title" do
    it "removes those results" do
      stub_request(:get, search_api_v1_url).to_return(
        body: {
          "results": [
            {
              "title" => "",
              "index" => "govuk",
              "es_score" => nil,
              "_id" => "",
            },
          ],
        }
        .to_json,
      )
      clear_cache
      expect(described_class.new.values).to be_empty
    end
  end

  describe "when search_api_v1 is unavailable" do
    before do
      search_api_v1_is_unavailable
      clear_cache
    end

    it "returns an (uncached) empty hash" do
      manual = described_class.new[slug]
      expect(manual).to be_nil
      expect(Rails.cache.fetch(described_class.new.cache_key)).to be_nil
    end
  end

  def search_api_v1_is_unavailable
    stub_request(:get, search_api_v1_url).to_return(status: 500)
  end

  def clear_cache
    Rails.cache.delete(described_class.new.cache_key)
  end

  def search_api_v1_results
    %({
      "results": [
        {
          "title": "Care and use of a Nimbus 2000",
          "index": "govuk",
          "es_score": "nil",
          "_id": "/guidance/care-and-use-of-a-nimbus-2000",
          "elasticsearch_type": "manual",
          "document_type": "manual"
        }
      ]
    })
  end
end
