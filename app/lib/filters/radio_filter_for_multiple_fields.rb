module Filters
  class RadioFilterForMultipleFields < Filter
    def query_hash
      find_filter(value)["filter"]
    end

    def filter_hashes
      raise NotImplementedError
    end

  private

    def value
      validated_value(params)
    end

    def default_value
      filter_hashes.find { |filter| filter["default"] }.fetch("value")
    end

    def validated_value(value)
      filter_hashes.map { |filter| filter["value"] }.include?(value) ? value : default_value
    end

    def find_filter(value)
      filter_hashes.find { |filter| filter["value"] == value }
    end
  end
end
