# typed: false
require "spec_helper"

describe Filters::DateFilter do
  subject(:date_filter) {
    Filters::DateFilter.new(facet, params)
  }

  let(:facet) { { "key" => "date_key" } }
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

  describe "#query_hash" do
    context "when to date is provided" do
      let(:params) {
        {
          to: "2015-06-27",
        }
      }

      it "include the to date" do
        expect(date_filter.query_hash).to eq("date_key" => "to:2015-06-27")
      end
    end

    context "when from date is provided" do
      let(:params) {
        {
          from: "2015-05-11",
        }
      }

      it "include the from date" do
        expect(date_filter.query_hash).to eq("date_key" => "from:2015-05-11")
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
        expect(date_filter.query_hash).to eq("date_key" => "to:2015-06-27,from:2015-05-11")
      end
    end
  end
end
