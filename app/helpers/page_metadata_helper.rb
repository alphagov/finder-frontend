module PageMetadataHelper
  def page_metadata(content_item)
    organisation_links = content_item.organisations.map do |organisation|
      link_to(organisation["title"], organisation["web_url"])
    end

    {}.tap do |metadata|
      metadata[:from] = organisation_links if organisation_links.present?
    end
  end
end
