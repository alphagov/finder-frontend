require "spec_helper"

describe DateInput do
  subject(:date_input) { described_class.new(original_input) }

  let(:original_input) { "01/01/2020" }
  let(:date_parser) { instance_double(DateParser, parse: parsed_date) }
  let(:parsed_date) { Date.new(1989, 12, 13) }

  before do
    allow(DateParser).to receive(:new).with(original_input).and_return(date_parser)
  end

  describe "#original_input" do
    it "returns the original input value" do
      expect(date_input.original_input).to eq(original_input)
    end
  end

  describe "#to_param" do
    it "returns the original input value" do
      expect(date_input.to_param).to eq(original_input)
    end
  end

  describe "#date" do
    it "returns the parsed date" do
      expect(date_input.date).to eq(Date.new(1989, 12, 13))
    end
  end

  describe "#to_iso8601" do
    it "returns the parsed date in ISO8601 format" do
      expect(date_input.to_iso8601).to eq("1989-12-13")
    end

    context "when the date cannot be parsed" do
      let(:parsed_date) { nil }

      it "returns nil" do
        expect(date_input.to_iso8601).to be_nil
      end
    end
  end
end
