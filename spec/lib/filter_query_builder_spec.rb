require "spec_helper"
require "filter_query_builder"

describe FilterQueryBuilder::DateFilter do
  subject(:date_filter) {
    FilterQueryBuilder::DateFilter.new(facet, params)
  }

  let(:facet) { double }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "should be false" do
        expect(date_filter).not_to be_active
      end
    end

    context "when empty dates are provided" do
      let(:params) {
        {
          from: "",
          to: "",
        }
      }

      it "should be false" do
        expect(date_filter).not_to be_active
      end
    end
  end

  describe "#value" do
    context "when to date is provided" do
      let(:params) {
        {
          to: "2015-06-27",
        }
      }

      it "include the to date" do
        expect(date_filter.value).to eq("to:2015-06-27")
      end
    end

    context "when from date is provided" do
      let(:params) {
        {
          from: "2015-05-11",
        }
      }

      it "include the from date" do
        expect(date_filter.value).to eq("from:2015-05-11")
      end
    end

    context "when both to and from dates are provided" do
      let(:params) {
        {
          to: "2015-06-27",
          from: "2015-05-11",
        }
      }

      it "include both to and from dates" do
        expect(date_filter.value).to eq("to:2015-06-27,from:2015-05-11")
      end
    end
  end
end

describe FilterQueryBuilder::TextFilter do
  subject(:text_filter) {
    FilterQueryBuilder::TextFilter.new(facet, params)
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
