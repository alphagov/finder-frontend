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

  let(:facet) {
    double(
      allowed_values: allowed_values,
    )
  }

  let(:allowed_values) { [] }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end

    context "when both params and allowed values are empty" do
      let(:params) { [] }

      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end

    context "when allowed_values is not empty and params is empty" do
      let(:allowed_values) {
        [
          double(value: :alpha),
        ]
      }

      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end

    context "when params is not empty and allowed_values is empty" do
      let(:params) { [:alpha] }

      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end

    context "when params and allowed_values do not intersect" do
      let(:params) { [:alpha] }
      let(:allowed_values) {
        [
          double(value: :beta),
        ]
      }

      it "should be false" do
        expect(text_filter).not_to be_active
      end
    end
  end

  describe "#value" do
    context "when params and allowed_values completely intersect" do
      let(:params) { [:alpha] }
      let(:allowed_values) {
        [
          double(value: :alpha),
        ]
      }

      it "should contain all values" do
        expect(text_filter.value).to eq([:alpha])
      end
    end

    context "when params and allowed_values partially intersect" do
      let(:params) { [:alpha, :beta] }
      let(:allowed_values) {
        [
          double(value: :beta),
          double(value: :gamma),
        ]
      }

      it "should contain only common values" do
        expect(text_filter.value).to eq([:beta])
      end
    end
  end
end
