require "spec_helper"

describe DateValidator do
  subject(:validator) { described_class.new(query) }

  let(:query) { instance_double(Search::Query, filter_params: { public_timestamp: }) }

  describe "#date_errors_hash" do
    subject(:date_errors_hash) { validator.date_errors_hash }

    describe "when dates are given as strings" do
      context "with empty dates" do
        let(:public_timestamp) { { from: "", to: "" } }

        it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
      end

      context "with valid dates" do
        let(:public_timestamp) { { from: "01/01/01", to: "01/01/01" } }

        it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
      end

      context "with a bad from date" do
        let(:public_timestamp) { { from: "99/99/99", to: "" } }

        it { is_expected.to eq(public_timestamp: { from: true, to: false }) }
      end

      context "with a bad to date" do
        let(:public_timestamp) { { from: "", to: "99/99/99" } }

        it { is_expected.to eq(public_timestamp: { from: false, to: true }) }
      end
    end

    describe "when dates are given as hashes" do
      context "with nil dates" do
        let(:public_timestamp) { { from: nil, to: nil } }

        it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
      end

      context "with empty hash dates" do
        let(:public_timestamp) { { from: {}, to: {} } }

        it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
      end

      context "with valid dates" do
        let(:public_timestamp) { { from: { day: "01", month: "01", year: "01" }, to: { day: "01", month: "01", year: "01" } } }

        it { is_expected.to eq(public_timestamp: { from: false, to: false }) }
      end

      context "with a bad from date" do
        let(:public_timestamp) { { from: { day: "99", month: "99", year: "99" }, to: {} } }

        it { is_expected.to eq(public_timestamp: { from: true, to: false }) }
      end

      context "with a bad to date" do
        let(:public_timestamp) { { from: {}, to: { day: "99", month: "99", year: "99" } } }

        it { is_expected.to eq(public_timestamp: { from: false, to: true }) }
      end
    end
  end
end
