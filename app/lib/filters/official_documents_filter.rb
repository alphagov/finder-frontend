module Filters
  class OfficialDocumentsFilter < Filter
    def query_hash
      find_filter(value)['filter']
    end

  private

    def value
      validated_value(params)
    end

    def default_value
      Filters.official_documents_filters.find { |filter| filter['default'] }.fetch('key')
    end

    def validated_value(value)
      Filters.official_documents_filters.map { |filter| filter['key'] }.include?(value) ? value : default_value
    end

    def find_filter(key)
      Filters.official_documents_filters.find { |filter| filter['key'] == key }
    end
  end
end
