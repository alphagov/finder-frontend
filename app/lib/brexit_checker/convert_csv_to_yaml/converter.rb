require "csv"
require "yaml"

module BrexitChecker
  module ConvertCsvToYaml
    class Converter
      attr_reader :processor, :action_validator

      def initialize(processor, action_validator = nil)
        @processor = processor
        @action_validator = action_validator
      end

      class ActionValidationError < StandardError; end

      def convert(csv_filename, yaml_filename, record_category = nil)
        csv = File.read(csv_filename)
        data = []

        CSV.parse(
          csv,
          headers: true,
          header_converters: convert_headers,
        )
           .each { |row| data << processor.process(row.to_h) }

        run_action_validations(data)

        write_to_yaml(data, yaml_filename, record_category)
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

      def run_action_validations(data)
        return unless action_validator

        data.compact.each do |row|
          action_validator.validate(row)
        end

        unless action_validator.errors.empty?
          raise ActionValidationError, action_validator.errors.to_s
        end
      end

      def write_to_yaml(data, yaml_filename, record_category)
        File.open(yaml_filename, "w") do |f|
          if record_category
            data_hash = { record_category => data.compact }
            f.puts data_hash.to_yaml
          else
            f.puts data.compact.to_yaml
          end
        end
      end
    end
  end
end
