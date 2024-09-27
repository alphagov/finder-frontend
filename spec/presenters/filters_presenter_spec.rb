require "spec_helper"

describe FiltersPresenter do
  subject { described_class.new(facets, finder_url_builder) }

  let(:facets) { [] }
  let(:finder_url_builder) { instance_double(UrlBuilder) }

  describe "#any_filters" do
    it "returns false" do
      expect(subject).not_to be_any_filters
    end
  end

  describe "#reset_url" do
    it "returns a static anchor link" do
      expect(subject.reset_url).to eq("#")
    end
  end

  describe "#summary_items" do
    it "returns an empty array" do
      expect(subject.summary_items).to eq([])
    end
  end
end
