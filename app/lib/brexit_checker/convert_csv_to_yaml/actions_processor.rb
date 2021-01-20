module BrexitChecker
  module ConvertCsvToYaml

    class ActionsProcessor
      LOGIC_FIELDS = %w[criteria].freeze
      COMMA_SEPARATED_FIELDS = %w[grouping_criteria].freeze
      ALLOWED_FIELDS = %w[title
                          title_url
                          consequence
                          guidance_prompt
                          guidance_link_text
                          guidance_url
                          lead_time
                          priority
                          criteria
                          audience
                          id
                          exception
                          grouping_criteria].freeze

      def initialize(batch = nil)
        @batch = batch
      end

      attr_reader :batch

      def process(record)
        return unless approved?(record)

        if batch
          return unless add_to_batch?(record)
        end

        stripped_record = remove_unnecessary_fields(record)
        stripped_record = parse_logic_fields(stripped_record)
        stripped_record = strip_trailing_whitespace(stripped_record)
        stripped_record = remove_empty_fields(stripped_record)
        stripped_record = parse_comma_separated(stripped_record)
        stripped_record["priority"] = stripped_record["priority"].to_i
        stripped_record
      end

    private

      def parse_comma_separated(record)
        COMMA_SEPARATED_FIELDS.each_with_object(record) do |field, hash|
          hash[field] = hash[field].split(",").map(&:strip) if hash[field]
        end
      end

      def parse_logic_fields(record)
        LOGIC_FIELDS.each_with_object(record) do |field, hash|
          hash[field] = BrexitChecker::Criteria::Parser.parse(hash[field].strip) if hash[field]
        end
      end

      def remove_unnecessary_fields(record)
        record.keep_if { |k, _v| ALLOWED_FIELDS.include?(k) }
      end

      def remove_empty_fields(record)
        record.keep_if { |_k, v| v.present? }
      end

      def strip_trailing_whitespace(record)
        (record.keys - LOGIC_FIELDS).each { |key| record[key] = record[key].strip if record[key] }
        record
      end

      def approved?(record)
        return unless record["status"]

        record["status"].downcase.strip == "approved"
      end

      def add_to_batch?(record)
        return unless record["batch"]

        record["batch"].downcase.strip == batch
      end
    end
  end
end
