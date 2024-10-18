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
  end
end
