require "spec_helper"

describe AdvancedSearchFinderPresenter do
  include ActionView::Helpers::UrlHelper

  subject(:presenter) { described_class.new(content_item_response, values) }

  let(:finder_item) {
    JSON.parse(File.read(Rails.root.join("features", "fixtures", "advanced-search.json")))
  }
  let(:content_item) {
    finder_item.merge("links" => {
      "taxons" => [{ "title" => "Education, training and skills", "base_path" => "/education" }]
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
      "content_purpose_supergroup" => "news_and_communications",
      "taxons" => "/education",
    }
  }

  describe "taxon_link" do
    it "builds a link to the taxon" do
      expected = link_to("Education, training and skills", "/education", class: "taxon-link")
      expect(subject.taxon_link).to eq(expected)
    end
  end

  describe "content_purpose_supergroups" do
    it "presents the correct supergroup" do
      expect(subject.content_purpose_supergroups.first.label).to eq(
        "News and communications"
      )
    end
  end

  describe "content_purpose_subgroups" do
    it "presents the correct subgroups for the supergroup" do
      expected = ["Updates and alerts", "News", "Speeches and statements"]
      expect(subject.content_purpose_subgroups).to eq(expected)
    end
  end

  describe "title" do
    it "presents the supergroup label" do
      expect(subject.title).to eq("News and communications")
    end

    context "without a supergroup" do
      let(:values) { { "taxons" => "/education" } }
      it "presents the taxon title" do
        expect(subject.title).to eq("Education, training and skills")
      end
    end

    context "with multiple supergroups" do
      let(:values) {
        {
          "taxons" => "/education",
          "content_purpose_supergroup" => %w(news_and_communications services)
        }
      }
      it "presents the supergroup labels in a sentence" do
        expect(subject.title).to eq("News and communications and Services")
      end
    end
  end

  describe "breadcrumbs" do
    let(:helper) { instance_double("GovukNavigationHelpers::TaxonBreadcrumbs") }
    let(:breadcrumb_data) {
      { breadcrumbs: [
        { title: "Home", url: "/", is_page_parent: false },
        { title: "Education, training and skills", url: "/education", is_page_parent: true },
        { title: "Latest on GOV.UK", is_current_page: true }
      ] }
    }

    before do
      allow(GovukNavigationHelpers::TaxonBreadcrumbs).to receive(:new).and_return(helper)
      allow(helper).to receive(:breadcrumbs).and_return(breadcrumb_data)
    end

    it "returns breadcrumbs which aren't the current page or the parent" do
      expected = { breadcrumbs: [{ title: "Home", url: "/", is_page_parent: false }] }
      expect(subject.breadcrumbs).to eq(expected)
    end
  end
end
