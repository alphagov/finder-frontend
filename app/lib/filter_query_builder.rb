# Used by the SearchQueryBuilder to build the `filter` part of the Rummager
# search query. This will determine the documents that are returned from rummager. 
class FilterQueryBuilder
  def initialize(facets:, user_params:)
    @facets = facets
    @user_params = user_params
  end

  def call
    filters.select(&:active?).reduce({}) { |query, filter|
      query.merge(filter.key => filter.value)
    }
  end

private
  attr_reader :facets, :user_params

  def filters
    @filters ||= facets.select(&:filterable).map { |f| build_filter(f) }
  end

  def build_filter(facet)
    filter_class = {
      'date' => DateFilter,
      'text' => TextFilter,
    }.fetch(facet.type)

    params = user_params.fetch(facet.key, nil)

    filter_class.new(facet, params)
  end

  class Filter
    def initialize(facet, params)
      @facet = facet
      @params = params
    end

    def key
      facet.key
    end

    def active?
      value.present?
    end

    def value
      raise NotImplementedError
    end

  private
    attr_reader :facet, :params
  end

  class DateFilter < Filter
    def value
      serialized_values.join(",")
    end

  private
    def serialized_values
      present_values.map { |key, date|
        "#{key}:#{date.iso8601}"
      }
    end

    def present_values
      parsed_values.select { |_, date|
        date.present?
      }
    end

    def parsed_values
      user_values.reduce({}) { |values, (key, date_string)|
        values.merge(key => DateParser.parse(date_string))
      }
    end

    def user_values
      params || {}
    end
  end

  class TextFilter < Filter
    def value
      Array(params)
    end
  end
end
