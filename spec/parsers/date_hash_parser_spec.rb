require "spec_helper"

RSpec.describe DateHashParser do
  subject(:parser) { described_class.new(date_hash) }

  around do |example|
    Timecop.freeze(Date.new(2024, 7, 21)) do
      example.run
    end
  end

  describe "#parse" do
    subject(:parsed_result) { parser.parse }

    describe "valid input" do
      context "with all fields provided" do
        let(:date_hash) { { day: 13, month: 12, year: 1989 } }

        it { is_expected.to eq Date.new(1989, 12, 13) }
      end

      context "with all fields provided as strings" do
        let(:date_hash) { { day: "13", month: "12", year: "1989" } }

        it { is_expected.to eq Date.new(1989, 12, 13) }
      end

      context "with month and year only" do
        let(:date_hash) { { month: 3, year: 2022 } }

        it { is_expected.to eq Date.new(2022, 3, 1) }
      end

      context "with year only" do
        let(:date_hash) { { year: 2024 } }

        it { is_expected.to eq Date.new(2024, 1, 1) }
      end

      context "with two digit year before 80" do
        let(:date_hash) { { year: 79 } }

        it { is_expected.to eq Date.new(2079, 1, 1) }
      end

      context "with two digit year after 80" do
        let(:date_hash) { { year: 81 } }

        it { is_expected.to eq Date.new(1981, 1, 1) }
      end

      context "with day and month only" do
        let(:date_hash) { { day: 1, month: 1 } }

        it { is_expected.to eq Date.new(2024, 1, 1) }
      end

      context "with month only" do
        let(:date_hash) { { month: 12 } }

        it { is_expected.to eq Date.new(2024, 12, 1) }
      end
    end

    describe "invalid input" do
      context "with invalid day" do
        let(:date_hash) { { day: 32, month: 1, year: 2023 } }

        it { is_expected.to be_nil }
      end

      context "with invalid month" do
        let(:date_hash) { { day: 1, month: 13, year: 2023 } }

        it { is_expected.to be_nil }
      end

      context "with day and year, but no month" do
        let(:date_hash) { { day: 1, year: 2023 } }

        it { is_expected.to be_nil }
      end

      context "with day, but no month or year" do
        let(:date_hash) { { day: 1 } }

        it { is_expected.to be_nil }
      end

      context "with hash with empty values" do
        let(:date_hash) { { day: "", month: "", year: "" } }

        it { is_expected.to be_nil }
      end

      context "with hash with non-numeric values" do
        let(:date_hash) { { day: "foo", month: "bar", year: "baz" } }

        it { is_expected.to be_nil }
      end

      context "with empty hash" do
        let(:date_hash) { {} }

        it { is_expected.to be_nil }
      end
    end
  end
end
