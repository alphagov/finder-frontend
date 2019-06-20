# typed: true
module Filters
  class RadioFilterForMultipleFields < Filter
    def query_hash
      find_filter(value)['filter']
    end

    def filter_hashes
      raise NotImplementedError
    end

  private

    def value
      validated_value(params)
    end

    def default_value
      filter_hashes.find { |filter| filter['default'] }.fetch('key')
    end

    def validated_value(value)
      filter_hashes.map { |filter| filter['key'] }.include?(value) ? value : default_value
    end

    def find_filter(key)
      filter_hashes.find { |filter| filter['key'] == key }
    end
  end
end
