require "spec_helper"

RSpec.describe AdvancedSearchResultSetPresenter do
  let(:finder_api) do
    AdvancedSearchFinderApi.new(
      "/search/advanced",
      filter_params
    ).content_item_with_search_results
  end
  let(:finder) { AdvancedSearchFinderPresenter.new(finder_api, filter_params) }
  let(:group) { "news_and_communications" }
  let(:filter_params) { { "topic" => "/education", "group" => group } }
  let(:view_context) { double(:view_context, render: nil) }
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

  subject(:instance) { described_class.new(finder, filter_params, view_context) }

  before do
    allow(Services.content_store).to receive(:content_item)
      .and_return(
        JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
      )
    allow(Services.content_store).to receive(:content_item)
      .with("/education")
      .and_return(taxon)
    allow(Services.rummager).to receive(:search)
      .and_return(search_results)
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
