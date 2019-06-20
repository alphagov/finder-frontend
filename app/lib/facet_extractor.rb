# typed: true
class FacetExtractor
  attr_reader :content_item

  def self.for(content_item)
    if facets_in_links?(content_item)
      FacetsFromFacetGroupExtractor.new(content_item['links']['facet_group'].first)
    else
      new(content_item)
    end
  end

  def initialize(content_item)
    @content_item = content_item
  end

  def extract
    content_item['details']['facets'] || []
  end

  def self.facets_in_links?(content_item)
    content_item.dig('links', 'facet_group').present? &&
      content_item['links']['facet_group'].first.present?
  end
end
