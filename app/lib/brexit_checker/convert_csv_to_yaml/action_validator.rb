module BrexitChecker
  module ConvertCsvToYaml
    class ActionValidator
      ALLOWED_CITIZEN_GROUPS = %w[visiting-eu
                                  visiting-uk
                                  visiting-ie
                                  living-eu
                                  living-ie
                                  living-uk
                                  working-uk
                                  studying-eu
                                  studying-uk
                                  common-travel-area].freeze

      def validate(action)
        validate_citizen_grouping_criteria(action)
      end

      def errors
        @errors ||= []
      end

    private

      def validate_citizen_grouping_criteria(action)
        return unless action["grouping_criteria"]

        unless ([action["grouping_criteria"]] - ALLOWED_CITIZEN_GROUPS).empty?
          add_error("#{action['id']} has invalid grouping criteria")
        end
      end

      def add_error(message)
        errors << message
      end
    end
  end
end
