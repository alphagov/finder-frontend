require "spec_helper"

describe BrexitChecker::ConvertCsvToYaml::ActionValidator do
  let(:valid_record) do
    {
      "id" => "S001",
      "grouping_criteria" => "visiting-eu",
    }
  end
  let(:invalid_record) do
    {
      "id" => "S002",
      "grouping_criteria" => %w[visiting-mars working-nasa],
    }
  end

  let(:validator) { described_class.new }

  describe "#validate" do
    it "logs an error if a record has invalid grouping criteria" do
      validator.validate(invalid_record)
      expect(validator.errors).to eq ["S002 has invalid grouping criteria"]
    end

    it "logs no error if a record is valid" do
      validator.validate(valid_record)
      expect(validator.errors).to eq([])
    end
  end
end
