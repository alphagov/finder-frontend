module PageMetadataHelper
  def page_metadata(content_item, filter_params)
    organisation_links = content_item.organisations.map do |organisation|
      link_to(organisation["title"], organisation["web_url"])
    end

    {}.tap do |metadata|
      metadata[:from] = organisation_links unless organisation_links.blank?
      metadata[:inverse] = true if topic_finder?(filter_params)
    end
  end
end
