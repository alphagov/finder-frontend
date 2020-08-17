MISSING_CSV_MESSAGE = "You must provide a path to the CSV file you would like to convert.".freeze

namespace :brexit_checker do
  namespace :convert_csv_to_yaml do
    desc "Import actions CSV and convert to YAML file"
    task :actions, [:csv_path] => :environment do |_, args|
      raise MISSING_CSV_MESSAGE unless args.csv_path

      processor = BrexitChecker::ConvertCsvToYaml::ActionsProcessor.new
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      csv_path = args.csv_path
      yaml_path = "app/lib/brexit_checker/actions.yaml"

      puts "> Converting #{csv_path} to YAML..."
      converter.convert(csv_path, yaml_path, "actions")
      puts "> #{csv_path} has been converted to #{yaml_path}."
    end

    desc "Download actions CSV from Google Drive and convert to YAML file"
    task actions_from_google_drive: :environment do
      sheet_id = ENV["GOOGLE_SHEET_ID"]
      csv_path = "tmp/actions.csv"
      BrexitChecker::ConvertCsvToYaml::GoogleDriveCsvDownloader.new(sheet_id, csv_path).download

      Rake::Task["brexit_checker:convert_csv_to_yaml:actions"].invoke(csv_path)
    end

    desc "Import criteria CSV and convert to YAML file"
    task :criteria, [:csv_path] => :environment do |_, args|
      raise MISSING_CSV_MESSAGE unless args.csv_path

      processor = BrexitChecker::ConvertCsvToYaml::CriteriaProcessor.new
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      csv_path = args.csv_path
      yaml_path = "app/lib/brexit_checker/criteria.yaml"

      puts "Converting #{csv_path} to YAML..."
      converter.convert(csv_path, yaml_path, "criteria")
      puts "#{csv_path} has been converted to #{yaml_path}."
    end
  end
end
