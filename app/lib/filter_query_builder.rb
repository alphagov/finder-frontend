# Used by the SearchQueryBuilder to build the `filter` part of the Rummager
# search query. This will determine the documents that are returned from rummager.
class FilterQueryBuilder
  def initialize(facets:, user_params:)
    @facets = facets
    @user_params = user_params
  end

  def call
    filters.select(&:active?).reduce({}) { |query, filter|
      query.merge(filter.key => filter_value(query, filter))
    }
  end

private

  attr_reader :facets, :user_params

  def filters
    @filters ||= facets.select { |f| f['filterable'] }.map { |f| build_filter(f) }
  end

  def build_filter(facet)
    filter_class = {
      'checkbox' => Filters::CheckboxFilter,
      'date' => Filters::DateFilter,
      'hidden' => Filters::HiddenFilter,
      'text' => Filters::TextFilter,
      'dropdown_select' => Filters::DropdownSelectFilter,
      'topical' => Filters::TopicalFilter,
      'taxon' => Filters::TaxonFilter,
      'radio' => Filters::RadioFilter,
      'content_id' => Filters::ContentIdFilter
    }.fetch(facet['type'])

    filter_class.new(facet, params(facet))
  end

  def filter_value(query, filter)
    # If the same filter key is provided multiple times, provide an array
    # of all values for that filter key
    return Array(query[filter.key]) + Array(filter.value) if query[filter.key]

    filter.value
  end

  def params(facet)
    facet_key = facet['key']
    facet_keys = facet['keys']

    if facet_keys
      return facet_keys.each_with_object({}) { |key, result_hash|
        result_hash[key] = user_params.fetch(key, nil)
      }
    end

    user_params.fetch(facet_key, nil)
  end
end
