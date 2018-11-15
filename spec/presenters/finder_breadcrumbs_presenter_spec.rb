require 'spec_helper'

RSpec.describe FinderBreadcrumbsPresenter do
  let(:finder) { JSON.parse(File.read(Rails.root.join("features", "fixtures", "aaib_reports_example.json"))) }
  let(:parent_content_item) { GovukSchemas::Example.find("organisation", example_name: "attorney_general") }
  let(:place_content_item) { GovukSchemas::Example.find("place", example_name: "find-regional-passport-office") }
  subject(:instance) { described_class.new(parent_content_item, finder) }

  describe "breadcrumbs" do
    it "has a link to home as the first entry" do
      expect(instance.breadcrumbs.first).to eql(title: "Home", url: "/")
    end

    it "has a link to all organisations when the document_type is organisation" do
      expect(parent_content_item["document_type"]).to eql("organisation")
      expect(instance.breadcrumbs.second).to eql(title: "Organisations", url: "/government/organisations")
    end

    it "has no links to organisations when the document_type is not organisation" do
      instance = described_class.new(place_content_item, finder)
      expect(place_content_item["document_type"]).to_not eql("organisation")
      expect(instance.breadcrumbs.second).to_not eql(title: "Organisations", url: "/government/organisations")
    end

    it "has an organisation link when the parent content item has a title and the document_type is organisation" do
      expect(parent_content_item["document_type"]).to eql("organisation")
      expect(instance.breadcrumbs.third).to eql(title: "Attorney General's Office", url: "/government/organisations/attorney-generals-office")
    end

    it "has no organisation link when the parent content item has no title and the document_type is organisation" do
      parent_content_item["title"] = ""
      instance = described_class.new(parent_content_item, finder)
      urls = instance.breadcrumbs.map { |breadcrumb| breadcrumb[:url] }
      expect(urls).to_not include("/government/organisations/attorney-generals-office")
    end

    it "displays finder title as text when the finder has a title" do
      expect(instance.breadcrumbs.last).to eql(title: "Air Accidents Investigation Branch reports", is_current_page: true)
    end

    it "does not display a finder title when the finder has no title" do
      finder["title"] = ""
      instance = described_class.new(parent_content_item, finder)
      titles = instance.breadcrumbs.map { |breadcrumb| breadcrumb[:title] }
      expect(titles).to_not include("Air Accidents Investigation Branch reports")
    end
  end
end
