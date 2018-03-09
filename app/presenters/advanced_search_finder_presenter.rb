class AdvancedSearchFinderPresenter < FinderPresenter
  def taxon
    # FIXME: This is probably too simplistic.
    content_item['links']['taxons'].first
  end

  def content_purpose_supergroups
    @content_purpose_supergroups ||=
      Supergroups.lookup(values['content_purpose_supergroup'])
  end

  def content_purpose_subgroups
    content_purpose_supergroups.map { |g| g.subgroups.map(&:humanize) }.flatten
  end

  def title
    return content_purpose_supergroups_to_sentence if content_purpose_supergroups.any?
    return taxon['title'] if taxon
    content_item['title']
  end

  def taxon_link
    link_to taxon['title'], taxon['base_path'], class: 'taxon-link'
  end

private

  def content_purpose_supergroups_to_sentence
    content_purpose_supergroups.map(&:label).to_sentence
  end
end
