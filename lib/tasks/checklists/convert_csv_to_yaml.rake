require "checklists/convert_csv_to_yaml/actions_processor.rb"
require "checklists/convert_csv_to_yaml/converter.rb"

MISSING_CSV_MESSAGE = "You must provide a path to the CSV file you would like to convert.".freeze

namespace :checklists do
  namespace :convert_csv_to_yaml do
    desc "Import actions CSV and convert to YAML file"
    task :actions, [:csv_path] => :environment do |_, args|
      abort MISSING_CSV_MESSAGE unless args.csv_path

      processor = Checklists::ConvertCsvToYaml::ActionsProcessor.new
      converter = Checklists::ConvertCsvToYaml::Converter.new(processor)
      csv_path = args.csv_path
      yaml_path = "lib/checklists/actions.yaml"

      puts "Converting #{csv_path} to YAML..."
      converter.convert(csv_path, yaml_path, "actions")
      puts "#{csv_path} has been converted to #{yaml_path}."
    end
  end
end
