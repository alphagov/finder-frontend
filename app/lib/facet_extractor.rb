class FacetExtractor
  attr_reader :content_item

  def initialize(content_item)
    @content_item = content_item
  end

  def extract
    content_item['details']['facets'] || []
  end
end
