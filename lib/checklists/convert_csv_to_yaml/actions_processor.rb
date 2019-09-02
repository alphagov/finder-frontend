module Checklists
  module ConvertCsvToYaml
    class ActionsProcessor
      LOGIC_FIELDS = %w(criteria).freeze
      ALLOWED_FIELDS = %w(title
                          title_url
                          consequence
                          guidance_prompt
                          guidance_link_text
                          guidance_url
                          lead_time
                          priority
                          criteria
                          audience
                          action_id
                          exception).freeze

      def process(record)
        return unless approved?(record)

        stripped_record = remove_unnecessary_fields(record)
        stripped_record = convert_logic_fields(stripped_record)
        stripped_record = strip_trailing_whitespace(stripped_record)
        stripped_record = remove_empty_fields(stripped_record)
        stripped_record["priority"] = stripped_record["priority"].to_i
        stripped_record
      end

    private

      def convert_logic_fields(record)
        LOGIC_FIELDS.each do |field|
          record[field] = record[field].gsub('AND', '&&').gsub('OR', '||') if record[field]
        end
        record
      end

      def remove_unnecessary_fields(record)
        record.keep_if { |k, _v| ALLOWED_FIELDS.include?(k) }
      end

      def remove_empty_fields(record)
        record.keep_if { |_k, v| v.present? }
      end

      def strip_trailing_whitespace(record)
        record.keys.each { |key| record[key] = record[key].strip if record[key] }
        record
      end

      def approved?(record)
        return unless record["status"]

        record["status"].downcase.strip == "approved"
      end
    end
  end
end
