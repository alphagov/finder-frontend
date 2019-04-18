module Filters
  class ResearchAndStatisticsFilter < Filter
    def query_hash
      find_filter(value)['filter']
    end

  private

    def value
      validated_value(params)
    end

    def default_value
      Filters.research_and_statistics_filters.find { |filter| filter['default'] }.fetch('key')
    end

    def validated_value(value)
      Filters.research_and_statistics_filters.map { |filter| filter['key'] }.include?(value) ? value : default_value
    end

    def find_filter(key)
      Filters.research_and_statistics_filters.find { |filter| filter['key'] == key }
    end
  end
end
