class AdvancedSearchFinderPresenter < FinderPresenter
  include AdvancedSearchParams

  def taxon
    # FIXME: This is probably too simplistic.
    content_item['links']['taxons'].first
  end

  def content_purpose_supergroups
    @content_purpose_supergroups ||=
      Supergroups.lookup(values[GROUP_SEARCH_FILTER])
  end

  def content_purpose_subgroups
    content_purpose_supergroups.map { |g| g.subgroups.map(&:humanize) }.flatten
  end

  def title
    content_purpose_supergroups_to_sentence
  end

  def taxon_link
    link_to taxon['title'], taxon['base_path'], class: 'taxon-link'
  end

  def breadcrumbs
    @data ||= GovukNavigationHelpers::TaxonBreadcrumbs.new(content_item).breadcrumbs
    filtered = @data[:breadcrumbs].reject { |bc| exclude_breadcrumb?(bc) }
    { breadcrumbs: filtered }
  end

private

  def exclude_breadcrumb?(breadcrumb)
    breadcrumb[:is_current_page] ||
      (breadcrumb[:url] != "/" && breadcrumb[:is_page_parent])
  end

  def content_purpose_supergroups_to_sentence
    content_purpose_supergroups.map(&:label).to_sentence
  end
end
