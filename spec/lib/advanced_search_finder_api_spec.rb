require "spec_helper"

describe AdvancedSearchFinderApi do
  let(:finder_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
  }
  let(:taxon_content_id) { SecureRandom.uuid }
  let(:taxon) {
    {
      "base_path" => "/education",
      "content_id" => taxon_content_id,
      "title" => "Education, training and skills",
    }
  }
  let(:filter_params) {
    {
      "taxons" => "/education",
      "content_purpose_supergroup" => "news_and_communications"
    }
  }
  let(:search_results) {
    {
      "results" => [],
      "total" => 0,
      "start" => 0,
      "current_page" => 1,
      "total_pages" => 1,
    }
  }

  subject(:instance) { described_class.new("/search/advanced", filter_params) }

  describe "content_item_with_search_results" do
    before do
      allow(Services.content_store).to receive(:content_item)
        .and_return(finder_item)

      allow(Services.content_store).to receive(:content_item)
        .with("/education")
        .and_return(taxon)

      expect(Services.rummager).to receive(:search)
        .and_return(
          "results" => [],
          "total" => 0,
          "start" => 0,
          "current_page" => 1,
          "total_pages" => 1,
        )
    end

    let(:composed_content_item) { instance.content_item_with_search_results }

    it "fetches a taxon" do
      instance.taxon

      expect(Services.content_store).to have_received(:content_item)
        .with("/education")
    end

    it "calls the search API with the taxon content_id" do
      instance.content_item_with_search_results

      expect(Services.rummager).to have_received(:search)
        .with(hash_including("filter_taxons" => taxon_content_id))
    end

    context "when an invalid taxon path is specified in params" do
      before do
        allow(Services.content_store).to receive(:content_item)
          .with("/doesnt-exist")
          .and_raise(GdsApi::ContentStore::ItemNotFound.new("ContentItem not found"))

        allow(Services.rummager).to receive(:search).and_return(search_results)
      end

      let(:filter_params) { { "taxons" => "/doesnt-exist" } }

      it "omits the taxon filter from search" do
        expect {
          instance.content_item_with_search_results
        }.not_to raise_error

        expect(Services.rummager).to have_received(:search)
          .with(hash_excluding("filter_taxons" => taxon_content_id))
      end
    end

    it "adds a taxon to the content item" do
      expect(composed_content_item["links"]["taxons"].first).to eq(taxon)
    end

    it "adds dynamic facet values" do
      facet = composed_content_item["details"]["facets"].find { |f| f["key"] == "content_purpose_subgroup" }
      facet_labels = facet["allowed_values"].map { |v| v["label"] }

      expect(facet_labels).to include("Speeches and statements")
    end

    context "when content_purpose_supergroup has one subgroup" do
      let(:filter_params) {
        {
          "part_of_taxonomy_tree" => "/education",
          "content_purpose_supergroup" => "services"
        }
      }

      it "hides the dynamic facet" do
        facet = composed_content_item["details"]["facets"].find { |f| f["key"] == "content_purpose_subgroup" }
        expect(facet["allowed_values"]).not_to be_empty
        expect(facet["type"]).to eq("hidden")
      end
    end

    context "when multiple supergroups are specified" do
      let(:filter_params) {
        {
          "part_of_taxonomy_tree" => "/education",
          "content_purpose_supergroup" => %w(news_and_communications services)
        }
      }
      it "returns a mixed list of subgroups" do
        facet = composed_content_item["details"]["facets"].find { |f| f["key"] == "content_purpose_subgroup" }
        facet_labels = facet["allowed_values"].map { |v| v["label"] }
        expected = ["Updates and alerts", "News", "Speeches and statements", "Transactions"]
        expect(facet_labels).to eq(expected)
      end
    end
  end
end
