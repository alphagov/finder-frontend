require "spec_helper"
require "csv_to_yaml_converter"

describe CsvToYamlConverter do
  include FixturesHelper
  let(:csv_file_path) { "#{fixtures_path}/csv_to_convert.csv" }
  let(:yaml_file_path) { Tempfile.new("a_file.yaml").path }

  describe "#convert" do
    it "converts CSV file data and writes to YAML file" do
      CsvToYamlConverter.new.convert(csv_file_path, yaml_file_path)
      yaml_file = File.read(yaml_file_path)
      expect(YAML.safe_load(yaml_file)).to include(
        a_hash_including("Audience" => "business")
      )
    end
  end
end
