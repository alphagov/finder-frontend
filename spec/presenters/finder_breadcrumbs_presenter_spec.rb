require "spec_helper"

RSpec.describe FinderBreadcrumbsPresenter do
  subject(:instance) { described_class.new(org_breadcrumb_info, finder) }

  let(:finder_hash) { JSON.parse(File.read(Rails.root.join("features/fixtures/aaib_reports_example.json"))) }
  let(:finder) { ContentItem.new(finder_hash) }
  let(:org_breadcrumb_info) { { "title" => "Attorney General's Office", "slug" => "attorney-generals-office" } }
  let(:empty_breadcrumb_info) { nil }

  describe "breadcrumbs" do
    it "returns nil if there is no breadcrumb info" do
      instance = described_class.new(empty_breadcrumb_info, finder)
      expect(instance.breadcrumbs).to be_nil
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
      expect(urls).not_to include("/government/organisations/attorney-generals-office")
    end
  end
end
