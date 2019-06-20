# typed: false
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
  let(:metadata_presenter_class) do
    MetadataPresenter
  end

  subject(:instance) { described_class.new(finder, filter_params, sort_presenter, metadata_presenter_class) }

  before do
    allow(Services.content_store).to receive(:content_item)
      .with("/education")
      .and_return(taxon)
    allow(Services.rummager).to receive(:search)
      .and_return("results" => search_results)
  end
end
