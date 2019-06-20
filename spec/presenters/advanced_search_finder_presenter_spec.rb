# typed: false
require "spec_helper"

describe AdvancedSearchFinderPresenter do
  include ActionView::Helpers::UrlHelper

  subject(:presenter) { described_class.new(content_item_response, search_results, values) }

  let(:finder_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
  }
  let(:search_results) { {} }
  let(:taxon_content_id) { SecureRandom.uuid }
  let(:content_item) {
    finder_item.merge("links" => {
      "taxons" => [{
        "base_path" => "/education",
        "content_id" => taxon_content_id,
        "title" => "Education, training and skills",
      }]
    })
  }

  let(:content_item_response) {
    dummy_http_response = double(
      "net http response",
      code: 200,
      body: content_item.to_json,
      headers: {}
    )
    GdsApi::Response.new(dummy_http_response).to_hash
  }

  let(:values) {
    {
      "group" => "policy_and_engagement",
      "topic" => "/education",
    }
  }

  describe "initialize" do
    let(:values) { { "topic" => taxon_content_id } }

    # The advanced search api rewrites the "topic" filter param with
    # the taxon content id to make a valid rummager query.
    # Pagination links from the result set presenter rely on the original
    # filter params so we need to restore the original topic value (the taxon's base path).
    it "replaces the taxon filter parameter with the taxon base path" do
      expect(subject.values["topic"]).to eq("/education")
    end
  end

  describe "taxon_link" do
    it "builds a link to the taxon" do
      expected = link_to("Education, training and skills", "/education", class: "taxon-link")
      expect(subject.taxon_link).to eq(expected)
    end
  end

  describe "content_purpose_supergroups" do
    it "presents the correct supergroup" do
      expect(subject.content_purpose_supergroups.first.label).to eq(
        "Policy papers and consultations"
      )
    end
  end

  describe "content_purpose_subgroups" do
    it "presents the correct subgroups for the supergroup" do
      expected = ["Policy papers", "Consultations"]
      expect(subject.content_purpose_subgroups).to eq(expected)
    end
  end

  describe "title" do
    it "presents the supergroup label" do
      expect(subject.title).to eq("Policy papers and consultations")
    end

    context "without a supergroup" do
      let(:values) { { "topic" => "/education" } }
      it "raises Supergroup::NotFound" do
        expect {
          subject.title
        }.to raise_error(Supergroups::NotFound)
      end
    end

    context "with multiple supergroups" do
      let(:values) {
        {
          "topic" => "/education",
          "group" => %w(policy_and_engagement services)
        }
      }
      it "presents the supergroup labels in a sentence" do
        expect(subject.title).to eq("Policy papers and consultations and Services")
      end
    end
  end

  describe "breadcrumbs" do
    let(:helper) { instance_double("GovukPublishingComponents::AppHelpers::TaxonBreadcrumbs") }
    let(:breadcrumb_data) {
      [
        { title: "Home", url: "/", is_page_parent: false },
        { title: "Education, training and skills", url: "/education", is_page_parent: true },
        { title: "Latest on GOV.UK", is_current_page: true }
      ]
    }

    before do
      allow(GovukPublishingComponents::AppHelpers::TaxonBreadcrumbs).to receive(:new).and_return(helper)
      allow(helper).to receive(:breadcrumbs).and_return(breadcrumb_data)
    end

    it "returns breadcrumbs which aren't the current page or the parent" do
      expected = { breadcrumbs: [{ title: "Home", url: "/", is_page_parent: false }] }
      expect(subject.breadcrumbs).to eq(expected)
    end

    context "for a root taxon" do
      let(:breadcrumb_data) {
        [
          { title: "Home", url: "/", is_page_parent: true },
          { title: "Latest on GOV.UK", is_current_page: true },
        ]
      }
      it "always includes the Home breadcrumb" do
        expect(subject.breadcrumbs[:breadcrumbs].first[:title]).to eq("Home")
        expect(subject.breadcrumbs[:breadcrumbs].first[:url]).to eq("/")
      end
    end
  end
end
