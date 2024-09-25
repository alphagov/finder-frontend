require "spec_helper"

describe Filters::DateFilter do
  subject(:date_filter) do
    described_class.new(facet, params)
  end

  let(:facet) { { "key" => "date_key" } }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "is false" do
        expect(date_filter).not_to be_active
      end
    end

    context "when empty dates are provided" do
      let(:params) do
        {
          from: "",
          to: "",
        }
      end

      it "is false" do
        expect(date_filter).not_to be_active
      end
    end
  end

  describe "#query_hash" do
    context "when to date is provided" do
      let(:params) do
        {
          to: "2015-06-27",
        }
      end

      it "include the to date" do
        expect(date_filter.query_hash).to eq("date_key" => "to:2015-06-27")
      end
    end

    context "when from date is provided" do
      let(:params) do
        {
          from: "2015-05-11",
        }
      end

      it "include the from date" do
        expect(date_filter.query_hash).to eq("date_key" => "from:2015-05-11")
      end
    end

    context "when both to and from dates are provided" do
      let(:params) do
        {
          to: "2015-06-27",
          from: "2015-05-11",
        }
      end

      it "include both to and from dates" do
        expect(date_filter.query_hash).to eq("date_key" => "to:2015-06-27,from:2015-05-11")
      end
    end
  end
end
