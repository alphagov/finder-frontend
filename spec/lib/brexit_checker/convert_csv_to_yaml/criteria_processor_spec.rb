require "spec_helper"

describe BrexitChecker::ConvertCsvToYaml::CriteriaProcessor do
  let(:record) do
    {
      "key" => "owns-operates-business-organisation",
      "text" => "Owns or operates business or organisation",
      "depends_on" => "something,another-thing",
      "fruit" => "bananas",
      "empty" => "",
    }
  end

  describe "#process" do
    it "removes unnecessary fields from a record" do
      result = described_class.new.process(record)
      expect(result).not_to include("fruit" => "bananas")
      expect(result).to include("key" => "owns-operates-business-organisation")
    end

    it "removes empty fields from a record" do
      result = described_class.new.process(record)
      expect(result).not_to include("empty")
    end

    it "converts comma-separated values to an array" do
      result = described_class.new.process(record)
      expect(result["depends_on"]).to eq(%w[something another-thing])
    end
  end
end
