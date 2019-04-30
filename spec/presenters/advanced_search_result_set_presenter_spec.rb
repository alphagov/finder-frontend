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
  let(:view_context) { double(:view_context, render: nil) }
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

  subject(:instance) { described_class.new(finder, filter_params, view_context, metadata_presenter_class) }

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

    context "applied filters, filtered with dates" do
      let(:filter_params) {
        {
          "topic" => "/education",
          "group" => "news_and_communications",
          "public_timestamp" => { "from" => "02-2017" },
        }
      }

      it "contains all subgroups and date filters" do
        expected = [[{
          data_facet: "public_timestamp",
          data_name: "public_timestamp[from]",
          data_track_label: " 1 February 2017",
          data_value: "02-2017",
          preposition: "Published After",
          text: " 1 February 2017"
        }]]
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
        expected = [
          [{
            data_facet: "subgroup",
            data_name: nil,
            data_track_label: "News",
            data_value: "news",
            preposition: "In",
            text: "News"
          }],
          [{
            data_facet: "public_timestamp",
            data_name: "public_timestamp[from]",
            data_track_label: " 1 February 2017",
            data_value: "02-2017",
            preposition: "Published After",
            text: " 1 February 2017"
          }]
        ]
        expect(instance.to_hash[:applied_filters]).to eq(expected)
      end
    end

    context "next and previous links" do
      let(:search_results) {
        {
          "results" => [],
          "total" => 30,
          "start" => 0,
          "current_page" => 1,
          "total_pages" => 2,
        }
      }
      let(:view_context) { ActionView::Base.new }
      let(:filter_params) {
        {
          "topic" => "/education",
          "group" => "news_and_communications",
        }
      }

      it "contains valid topic (base_path) filtering params" do
        expect(view_context).to receive(:render)
          .with(
            formats: %w(html),
            partial: 'govuk_publishing_components/components/previous_and_next_navigation',
            locals: {
              next_page: {
                label: "2 of 2",
                title: "Next page",
                url: "/search/advanced?group=news_and_communications&page=2&topic=%2Feducation"
              }
            }
          )

        instance.to_hash
      end
    end
  end
end
