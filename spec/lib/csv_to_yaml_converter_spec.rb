require "spec_helper"
require "csv_to_yaml_converter"

describe CsvToYamlConverter do
  include FixturesHelper
  let(:csv_file_path) { "#{fixtures_path}/csv_to_convert.csv" }
  let(:yaml_file_path) { Tempfile.new("a_file.yaml").path }
  let(:fields) do
    %w(title
       title_url
       consequence
       guidance_prompt
       guidance_link_text
       guidance_url
       lead_time
       priority
       criteria
       audience)
  end

  describe "#convert" do
    let(:loaded_yaml_file) { YAML.safe_load(File.read(yaml_file_path)) }

    before do
      CsvToYamlConverter.new(fields).convert(csv_file_path, yaml_file_path)
    end

    it "converts CSV file data to YAML and writes to a YAML file" do
      expect(loaded_yaml_file).to include(
        a_hash_including("title_url" => "https://www.gov.uk/important-action")
      )
    end

    it "only writes data for a list of given fields to the YAML file" do
      expect(loaded_yaml_file).not_to include(
        a_hash_including("owner" => "John Doe")
      )
    end
  end
end
