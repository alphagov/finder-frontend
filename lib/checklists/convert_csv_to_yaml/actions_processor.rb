module Checklists
  module ConvertCsvToYaml
    class ActionsProcessor
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
      end

    private

      def remove_unnecessary_fields(record)
        record.keep_if { |k, _v| ALLOWED_FIELDS.include?(k) }
      end
    end
  end
end
