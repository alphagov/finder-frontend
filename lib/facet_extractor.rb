class FacetExtractor
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item.as_hash
  end

  def extract
    facets_in_links = content_item.dig("links", "facet_group", 0, "links", "facets") || []
    facets_in_details = content_item.dig("details", "facets") || []
    facets_in_details + facets_in_links.map { |facet_in_link| transform_hash(facet_in_link) }
  end

private

  def transform_hash(facet_in_links)
    facet_details = facet_in_links["details"]
    {
      "name" => facet_details["name"],
      "short_name" => facet_details["short_name"],
      "key" => facet_details["key"],
      "display_as_result_metadata" => facet_details["display_as_result_metadata"],
      "filterable" => facet_details["filterable"],
      "filter_key" => facet_details["filter_key"],
      "combine_mode" => facet_details["combine_mode"] || "and",
      "preposition" => facet_details["preposition"],
      "type" => facet_details["type"],
      "allowed_values" => facet_in_links.dig("links", "facet_values").map do |facet_value|
        {
          "label" => facet_value.dig("details", "label"),
          "value" => facet_value.dig("details", "value"),
          "content_id" => facet_value["content_id"],
        }
      end,
    }.compact
  end
end
