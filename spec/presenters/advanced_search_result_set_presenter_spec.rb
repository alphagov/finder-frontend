require "spec_helper"

RSpec.describe AdvancedSearchResultSetPresenter do
  let(:content_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
  }
  let(:finder_api) do
    AdvancedSearchFinderApi.new(
      content_item,
      filter_params
    ).content_item_with_search_results
  end

  let(:group) { "news_and_communications" }
  let(:filter_params) { { "topic" => "/education", "group" => group } }
  let(:finder) { AdvancedSearchFinderPresenter.new(finder_api, search_results, sort_presenter, filter_params) }
  let(:next_and_prev_links) { double(:next_and_prev_links) }
  let(:sort_presenter) {
    double(
      SortPresenter,
      selected_option: nil,
      to_hash: {},
    )
  }
  let(:taxon_content_id) { SecureRandom.uuid }
  let(:taxon) {
    {
      "base_path" => "/education",
      "content_id" => taxon_content_id,
      "title" => "Education"
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

  subject(:instance) { described_class.new(finder, filter_params, sort_presenter, next_and_prev_links) }

  before do
    allow(Services.content_store).to receive(:content_item)
      .with("/education")
      .and_return(taxon)
    allow(Services.rummager).to receive(:batch_search)
      .and_return("results" => [search_results])
  end

  describe "#to_hash" do
    it "doesn't include an atom url" do
      expect(instance.to_hash.keys).not_to include(:atom_url)
    end

    it "contains group filters in lower case" do
      expected = "in updates and alerts, news, speeches and statements, and decisions"
      expect(instance.to_hash[:applied_filters]).to eq(expected)
    end

    context "applied filters, filtered with dates" do
      let(:filter_params) {
        {
          "topic" => "/education",
          "group" => "news_and_communications",
          "public_timestamp" => { "from" => "02-2017" },
        }
      }

      it "contains all subgroups and date filters" do
        expected = "in updates and alerts, news, speeches and statements, and decisions and published after 1 February 2017"
        expect(instance.to_hash[:applied_filters]).to eq(expected)
      end
    end

    context "applied filters, filtered with dates and subgroups" do
      let(:filter_params) {
        {
          "topic" => "/education",
          "group" => "news_and_communications",
          "subgroup" => "news",
          "public_timestamp" => { "from" => "02-2017" },
        }
      }

      it "contains selected subgroups and date filters" do
        expected = "in News published after 1 February 2017"
        expect(instance.to_hash[:applied_filters]).to eq(expected)
      end
    end
  end
end
