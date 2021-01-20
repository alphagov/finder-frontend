MISSING_CSV_MESSAGE = "You must provide a path to the CSV file you would like to convert.".freeze
MISSING_BATCH_ID = "You must provide a batch id"
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

    ## temporary
    desc "Import batched actions CSV and convert to YAML file"
    task :batched_actions, [:csv_path, :batch_id] => :environment do |_, args|
      raise MISSING_CSV_MESSAGE unless args.csv_path
      raise MISSING_CSV_MESSAGE unless args.batch_id
      processor = BrexitChecker::ConvertCsvToYaml::ActionsProcessor.new(args.batch_id)
      converter = BrexitChecker::ConvertCsvToYaml::Converter.new(processor)
      yaml_path = "app/lib/brexit_checker/batched_actions/#{args.batch_id}.yaml"

      puts "> Converting #{args.csv_path} to YAML..."
      converter.convert(args.csv_path, yaml_path, "actions")
      puts "> #{args.csv_path} has been converted to #{yaml_path}."
    end

    ## temporary
    desc "Download batched actions CSV from Google Drive and convert to YAML file"
    task :batched_actions_from_google_drive, [:batch_id] => :environment do |_, args|
      raise MISSING_CSV_MESSAGE unless args.batch_id
      sheet_id = ENV["GOOGLE_SHEET_ID"]
      csv_path = "tmp/actions_for_#{args.batch_id}.csv"
      BrexitChecker::ConvertCsvToYaml::GoogleDriveCsvDownloader.new(sheet_id, csv_path).download

      Rake::Task["brexit_checker:convert_csv_to_yaml:batched_actions"].invoke(csv_path, args.batch_id)
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
