require "spec_helper"

describe DateParser do
  subject(:date_parser) { described_class.new(date_param) }

  describe "#parse" do
    context "when given a string" do
      let(:date_param) { "13/12/1989" }

      it "delegates to DateStringParser" do
        expect(date_parser.parse).to eq(Date.new(1989, 12, 13))
      end
    end

    context "when given a hash" do
      let(:date_param) { { day: 17, month: 8, year: 2024 } }

      it "delegates to DateHashParser" do
        expect(date_parser.parse).to eq(Date.new(2024, 8, 17))
      end
    end

    context "when given nil" do
      let(:date_param) { nil }

      it "returns nil" do
        expect(date_parser.parse).to be_nil
      end
    end

    context "when given an unexpected object" do
      let(:date_param) { Object.new }

      it "raises an error" do
        expect { date_parser.parse }.to raise_error(ArgumentError, /be a String, Hash, or nil/)
      end
    end
  end
end
