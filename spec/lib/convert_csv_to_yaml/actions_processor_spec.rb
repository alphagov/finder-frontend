require "spec_helper"
require "convert_csv_to_yaml/actions_processor"

describe ConvertCsvToYaml::ActionsProcessor do
  let(:record) do
    {
      "owner" => "John Doe",
      "title" => "A title",
      "criteria" => "owns-business,imports-eu",
    }
  end

  describe "#process" do
    it "removes unnecessary fields from a record" do
      result = described_class.new.process(record)
      expect(result).not_to include("owner" => "John Doe")
      expect(result).to include("title" => "A title")
    end

    it "converts comma-separated values to an array" do
      result = described_class.new.process(record)
      expect(result["criteria"]).to eq(%w(owns-business imports-eu))
    end
  end
end
