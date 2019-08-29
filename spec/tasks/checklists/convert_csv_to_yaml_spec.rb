require "spec_helper"
require "rake"

RSpec.describe "Convert CSV to YAML tasks" do
  include FixturesHelper

  before do
    Rake.application.rake_require "tasks/checklists/convert_csv_to_yaml"
    Rake::Task.define_task(:environment)
  end

  describe "checklists:convert_csv_to_yaml:actions" do
    before do
      Rake::Task["checklists:convert_csv_to_yaml:actions"].reenable
    end

    let(:actions_yaml_file_path) { Tempfile.new("actions.yaml").path }
    let(:actions_csv_file_path) { actions_csv_to_convert_to_yaml }

    it "converts the actions CSV to YAML and writes to the actions.yml file" do
      # Override the YAML file path that is sent to the Converter with a tempfile
      # so that "lib/checklists/actions.yaml" isn't overwritten by the test.
      allow_any_instance_of(Checklists::ConvertCsvToYaml::Converter).to receive(:convert).and_wrap_original do |m|
        m.call(actions_csv_file_path, actions_yaml_file_path, "actions")
      end

      Rake::Task["checklists:convert_csv_to_yaml:actions"].invoke(actions_csv_file_path)
      loaded_yaml_file = YAML.safe_load(File.read(actions_yaml_file_path))

      expect(loaded_yaml_file["actions"]).to include(
        a_hash_including(
          "action_id" => "T001",
          "audience" => "business",
          "consequence" => "If you don't do the important action then it will be bad.",
          "criteria" => "owns-business,imports-eu",
          "guidance_link_text" => "Some important guidance",
          "guidance_prompt" => "Read the guidance:",
          "guidance_url" => "https://www.gov.uk/guidance/important-guidance",
          "lead_time" => "1 week or less",
          "priority" => "High",
          "title" => "An important action",
          "title_url" => "https://www.gov.uk/important-action",
        )
      )
    end

    it "raises an error if a path is provided to a file that doesn't have .csv extension" do
      expect { Rake::Task["checklists:convert_csv_to_yaml:actions"].invoke }
        .to raise_error "You must provide a path to the CSV file you would like to convert."
    end
  end

  describe "checklists:convert_csv_to_yaml:criteria" do
    before do
      Rake::Task["checklists:convert_csv_to_yaml:criteria"].reenable
    end

    let(:criteria_yaml_file_path) { Tempfile.new("criteria.yaml").path }
    let(:criteria_csv_file_path) { criteria_csv_to_convert_to_yaml }

    it "converts the criteria CSV to YAML and writes to the criteria.yml file" do
      # Override the YAML file path that is sent to the Converter with a tempfile
      # so that "lib/checklists/criteria.yaml" isn't overwritten by the test.
      allow_any_instance_of(Checklists::ConvertCsvToYaml::Converter).to receive(:convert).and_wrap_original do |m|
        m.call(criteria_csv_file_path, criteria_yaml_file_path, "criteria")
      end

      Rake::Task["checklists:convert_csv_to_yaml:criteria"].invoke(criteria_csv_file_path)
      loaded_yaml_file = YAML.safe_load(File.read(criteria_yaml_file_path))

      expect(loaded_yaml_file["criteria"]).to include(
        a_hash_including(
          "key" => "owns-operates-business-organisation",
          "text" => "Owns or operates business or organisation",
          "depends_on" => %w(something another-thing),
        )
      )
    end

    it "raises an error if a path is provided to a file that doesn't have .csv extension" do
      expect { Rake::Task["checklists:convert_csv_to_yaml:criteria"].invoke }
        .to raise_error "You must provide a path to the CSV file you would like to convert."
    end
  end
end
