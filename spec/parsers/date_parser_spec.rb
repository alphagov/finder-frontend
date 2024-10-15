require "spec_helper"

describe DateParser do
  subject(:date_parser) { described_class.new(date_param) }

  let(:date_param) { "13/12/1989" }

  describe "#parse" do
    it "delegates to DateStringParser" do
      expect(date_parser.parse).to eq(Date.new(1989, 12, 13))
    end
  end
end
