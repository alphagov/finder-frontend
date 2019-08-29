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
                          action_id).freeze

      def process(record)
        stripped_record = remove_unnecessary_fields(record)
        convert_logic_fields(stripped_record)
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
    end
  end
end
