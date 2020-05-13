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

        CSV.parse(csv,
                  headers: true,
                  header_converters: downcase_underscore_headers)
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

      def downcase_underscore_headers
        ->(field, _) { field.downcase.gsub(" ", "_") }
      end
    end
  end
end
