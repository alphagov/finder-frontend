require "csv"
require "yaml"

class CsvToYamlConverter
  def initialize; end

  def convert(csv_filename, yaml_filename)
    csv = File.read(csv_filename)
    data = []

    CSV.parse(csv,
              headers: true,
              header_converters: downcase_underscore_headers)
       .each { |row| data << row.to_h }

    File.open(yaml_filename, "w") { |f| f.puts data.to_yaml }
  end

private

  def downcase_underscore_headers
    lambda { |field, _| field.downcase.gsub(" ", "_") }
  end
end
