require "spec_helper"

describe BrexitChecker::ConvertCsvToYaml::ActionsProcessor do
  let(:record) do
    {
      "owner" => "John Doe",
      "title" => "A title",
      "criteria" => "owns-business OR (imports-eu AND something)",
      "status" => "Approved",
      "guidance" => "",
    }
  end

  describe "#process" do
    it "removes unnecessary fields from a record" do
      result = described_class.new.process(record)
      expect(result.keys).not_to include("owner")
      expect(result.keys).to include("title")
      expect(result.keys).to include("criteria")
    end

    it "removes empty fields from a record" do
      result = described_class.new.process(record)
      expect(result).not_to include("guidance")
    end

    it "parses criteria" do
      result = described_class.new.process(record)
      expect(result).to include("criteria" => [{ "any_of" => ["owns-business", { "all_of" => %w(imports-eu something) }] }])
    end

    it "ignores empty criteria field" do
      record.delete("criteria")
      result = described_class.new.process(record)
      expect(result).not_to include("criteria" => nil)
    end

    it "strips trailing whitespace from record values" do
      record["consequence"] = "A consequence with some whitespace.    "
      result = described_class.new.process(record)
      expect(result["consequence"]).to eq("A consequence with some whitespace.")
    end

    it "does not return a record if its status is not 'Approved'" do
      record["status"] = "Hold"
      result = described_class.new.process(record)
      expect(result).to be nil
    end

    it "parses single grouping_criteria" do
      result = described_class.new.process(record.merge("grouping_criteria" => "group1"))
      expect(result.keys).to include("grouping_criteria")
      expect(result["grouping_criteria"]).to eq(%w(group1))
    end

    it "parses double grouping_criteria" do
      result = described_class.new.process(record.merge("grouping_criteria" => "group1, group2"))
      expect(result.keys).to include("grouping_criteria")
      expect(result["grouping_criteria"]).to eq(%w(group1 group2))
    end
  end
end
