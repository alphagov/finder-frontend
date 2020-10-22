require "spec_helper"

describe BrexitChecker::ConvertCsvToYaml::Converter do
  include FixturesHelper
  let(:csv_file_path) { actions_csv_to_convert_to_yaml }
  let(:yaml_file_path) { Tempfile.new("a_file.yaml").path }
  let(:processor) { double("processor") }

  describe "#convert" do
    let(:loaded_yaml_file) { YAML.safe_load(File.read(yaml_file_path)) }

    before do
      allow(processor).to receive(:process)
                      .and_return({ "title_url" => "https://www.gov.uk/important-action" },
                                  "title_url" => "https://www.gov.uk/important-action-2")
    end

    it "converts CSV file data to YAML and writes to a YAML file" do
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      converter.convert(csv_file_path, yaml_file_path)

      expect(loaded_yaml_file).to include(
        "title_url" => "https://www.gov.uk/important-action",
      )
    end

    it "allows an optional record category to be set as a key in the YAML file" do
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      converter.convert(csv_file_path, yaml_file_path, "category")

      expect(loaded_yaml_file).to eq(
        "category" => [
          { "title_url" => "https://www.gov.uk/important-action" },
          { "title_url" => "https://www.gov.uk/important-action-2" },
        ],
      )
    end

    it "removes nil values from the records array before writing to the YAML file" do
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      converter.convert(csv_file_path, yaml_file_path)

      expect(loaded_yaml_file).not_to include(
        "title" => "Another important action",
      )
    end

    context "when a validator is provided" do
      let(:validator) { double("validator") }

      before do
        allow(validator).to receive(:validate)
      end

      it "if the csv contains a bad action it raises an error and does not write to yaml" do
        allow(validator).to receive(:errors).and_return(["S001 has invalid grouping criteria"])

        converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor, validator)
        validation_error = BrexitChecker::ConvertCsvToYaml::Converter::ActionValidationError

        expect { converter.convert(csv_file_path, yaml_file_path) }.to raise_error(validation_error)
        expect(loaded_yaml_file).to be_nil
      end

      it "if the csv contains valid actions it writes to yaml" do
        allow(validator).to receive(:errors).and_return([])

        converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor, validator)

        expect { converter.convert(csv_file_path, yaml_file_path) }.not_to raise_error
        expect(loaded_yaml_file).to include(
          "title_url" => "https://www.gov.uk/important-action",
        )
      end
    end
  end
end
