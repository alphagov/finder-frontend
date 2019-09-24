require "spec_helper"

RSpec.describe FinderBreadcrumbsPresenter do
  let(:finder_hash) { JSON.parse(File.read(Rails.root.join("features", "fixtures", "aaib_reports_example.json"))) }
  let(:finder) { ContentItem.new(finder_hash) }
  let(:org_breadcrumb_info) { { "title" => "Attorney General's Office", "slug" => "attorney-generals-office" } }
  let(:empty_breadcrumb_info) { nil }
  subject(:instance) { described_class.new(org_breadcrumb_info, finder) }

  describe "breadcrumbs" do
    it "returns nil if there is no breadcrumb info" do
      instance = described_class.new(empty_breadcrumb_info, finder)
      expect(instance.breadcrumbs).to be nil
    end

    it "has a link to home as the first entry" do
      expect(instance.breadcrumbs.first).to eql(title: "Home", url: "/")
    end

    it "has organisation breadcrumbs when the breadcrumb hash is populated" do
      expect(instance.breadcrumbs.second).to eql(title: "Organisations", url: "/government/organisations")
      expect(instance.breadcrumbs.third).to eql(title: "Attorney General's Office", url: "/government/organisations/attorney-generals-office")
    end

    it "has no organisation link when the breadcrumb hash is invalid" do
      org_breadcrumb_info["title"] = ""
      instance = described_class.new(org_breadcrumb_info, finder)
      urls = instance.breadcrumbs.map { |breadcrumb| breadcrumb[:url] }
      expect(urls).to_not include("/government/organisations/attorney-generals-office")
    end

    it "displays finder title as text when the finder has a title" do
      expect(instance.breadcrumbs.last).to eql(title: "Air Accidents Investigation Branch reports", is_current_page: true)
    end

    it "does not display a finder title when the finder has no title" do
      finder_hash["title"] = ""
      instance = described_class.new(org_breadcrumb_info, finder)
      titles = instance.breadcrumbs.map { |breadcrumb| breadcrumb[:title] }
      expect(titles).to_not include("Air Accidents Investigation Branch reports")
    end
  end
end
