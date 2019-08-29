module Checklists
  module ConvertCsvToYaml
    class CriteriaProcessor
      COMMA_SEPARATED_FIELDS = %w(depends_on).freeze
      ALLOWED_FIELDS = %w(key
                          text
                          depends_on).freeze

      def process(record)
        stripped_record = remove_unnecessary_fields(record)
        convert_comma_separated_values_to_array(stripped_record)
      end

    private

      def convert_comma_separated_values_to_array(record)
        COMMA_SEPARATED_FIELDS.each do |field|
          record[field] = record[field].split(",") if record[field]
        end
        record
      end

      def remove_unnecessary_fields(record)
        record.keep_if { |k, _v| ALLOWED_FIELDS.include?(k) }
      end
    end
  end
end
