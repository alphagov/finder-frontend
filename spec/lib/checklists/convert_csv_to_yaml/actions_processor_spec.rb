require "spec_helper"
require "checklists/convert_csv_to_yaml/actions_processor"

describe Checklists::ConvertCsvToYaml::ActionsProcessor do
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
      expect(result).to include("criteria" => "owns-business,imports-eu")
    end
  end
end
