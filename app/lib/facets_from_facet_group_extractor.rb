# typed: true
class FacetsFromFacetGroupExtractor
  def initialize(facet_group)
    @facets = facet_group.dig('links', 'facets') || []
  end

  def extract
    facets.map(&method(:extract_facet))
  end

private

  attr_reader :facets

  def extract_facet(facet)
    facet_details = facet['details']
    {
      'name' => facet_details['name'],
      'short_name' => facet_details['short_name'],
      'key' => facet_details['key'],
      'display_as_result_metadata' => facet_details['display_as_result_metadata'],
      'filterable' => facet_details['filterable'],
      'filter_key' => facet_details['filter_key'],
      'combine_mode' => facet_details['combine_mode'] || 'and',
      'preposition' => facet_details['preposition'],
      'type' => facet_details['type'],
      'allowed_values' => facet['links']['facet_values'].map(&method(:extract_allowed_values))
    }.compact
  end

  def extract_allowed_values(facet_value)
    {
      'label' => facet_value['details']['label'],
      'value' => facet_value['details']['value'],
      'content_id' => facet_value['content_id']
    }
  end
end
