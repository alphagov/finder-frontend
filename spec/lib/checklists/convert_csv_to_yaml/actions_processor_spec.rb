require "spec_helper"
require "checklists/convert_csv_to_yaml/actions_processor"

describe Checklists::ConvertCsvToYaml::ActionsProcessor do
  let(:record) do
    {
      "owner" => "John Doe",
      "title" => "A title",
      "criteria" => "owns-business",
    }
  end

  describe "#process" do
    it "removes unnecessary fields from a record" do
      result = described_class.new.process(record)
      expect(result).not_to include("owner" => "John Doe")
      expect(result).to include("title" => "A title")
      expect(result).to include("criteria" => "owns-business")
    end

    it "converts AND logic criteria" do
      record['criteria'] = 'owns-business AND imports-eu'
      result = described_class.new.process(record)
      expect(result).to include("criteria" => "owns-business && imports-eu")
    end

    it "converts OR logic criteria" do
      record['criteria'] = 'owns-business OR imports-eu'
      result = described_class.new.process(record)
      expect(result).to include("criteria" => "owns-business || imports-eu")
    end

    it "converts OR and AND logic criteria" do
      record['criteria'] = 'owns-business OR imports-eu AND something'
      result = described_class.new.process(record)
      expect(result).to include("criteria" => "owns-business || imports-eu && something")
    end

    it "converts OR and AND logic criteria" do
      record.delete('criteria')
      result = described_class.new.process(record)
      expect(result).not_to include("criteria" => nil)
    end
  end
end
