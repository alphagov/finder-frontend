require "csv"
require "yaml"

module BrexitChecker
  module ConvertCsvToYaml
    class Converter
      attr_reader :processor

      def initialize(processor)
        @processor = processor
      end

      def convert(csv_filename, yaml_filename, record_category = nil)
        csv = File.read(csv_filename)
        data = []

        CSV.parse(
          csv,
          headers: true,
          header_converters: convert_headers,
        )
           .each { |row| data << processor.process(row.to_h) }

        File.open(yaml_filename, "w") do |f|
          if record_category
            data_hash = { record_category => data.compact }
            f.puts data_hash.to_yaml
          else
            f.puts data.compact.to_yaml
          end
        end
      end

    private

      FIELD_NAME_OVERRIDES = {
        "Priority (1 is low, 10 is high)" => "priority",
      }.freeze

      def convert_headers
        lambda { |field, _|
          field = FIELD_NAME_OVERRIDES[field] || field
          field.downcase.gsub(" ", "_")
        }
      end
    end
  end
end
