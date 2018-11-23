require "spec_helper"

describe Filters::TextFilter do
  subject(:text_filter) {
    Filters::TextFilter.new(facet, params)
  }

  let(:facet) { double }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end

    context "when params is empty" do
      let(:params) { [] }

      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end
  end

  describe "#key" do
    context "when a filter_key is present" do
      let(:facet) { { "filter_key" => "alpha", "key" => "beta" } }

      it "returns filter_key" do
        expect(text_filter.key).to eq("alpha")
      end
    end

    context "when a filter_key is not present" do
      let(:facet) { { "key" => "beta" } }

      it "returns key" do
        expect(text_filter.key).to eq("beta")
      end
    end
  end

  describe "#value" do
    context "when params is present" do
      let(:params) { [:alpha] }

      it "should contain all values" do
        expect(text_filter.value).to eq([:alpha])
      end
    end
  end
end
