class BusinessSupportChecker::Criteria::Extractor
  class << self
    def extract(expression)
      case expression
      when Array
        expression.flat_map { |element| extract(element) }
      when Hash
        extract(expression.symbolize_keys.fetch(:any_of, [])) +
          extract(expression.symbolize_keys.fetch(:all_of, []))
      when String
        [expression]
      end
    end
  end
end
