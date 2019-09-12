class FinderBreadcrumbsPresenter
  attr_reader :organisation, :finder_name

  def initialize(organisation, finder_content_item)
    @organisation = organisation
    @finder_name = finder_content_item.title
  end

  def breadcrumbs
    return nil if organisation.blank?

    crumbs = [{ title: "Home", url: "/" }]
    crumbs << { title: "Organisations", url: "/government/organisations" }

    if organisation_is_valid?
      crumbs << { title: organisation["title"], url: "/government/organisations/#{organisation['slug']}" }
    end

    if finder_name.present?
      crumbs << { title: finder_name, is_current_page: true }
    end

    crumbs
  end

private

  def organisation_is_valid?
    organisation.present? && %w(title slug).all? { |key| organisation[key].present? }
  end
end
