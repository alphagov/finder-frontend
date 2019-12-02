class BrexitChecker::Criteria::Extractor
  class << self
    def expression_criteria(expression)
      extract_criteria(expression).flatten.to_set
    end

  private

    def extract_criteria(criteria)
      case criteria
      when Array
        criteria.flat_map { |element| extract_criteria(element) }
      when Hash
        extract_criteria(criteria.symbolize_keys.fetch(:any_of, [])) +
          extract_criteria(criteria.symbolize_keys.fetch(:all_of, []))
      when String
        [criteria]
      end
    end
  end
end
