class FinderBreadcrumbsPresenter
  def initialize(parent_content_item, finder_content_item)
    @parent_content_item = parent_content_item
    @finder_name = finder_content_item.dig("title")
  end

  def breadcrumbs
    crumbs = [{ title: "Home", url: "/" }]

    if @parent_content_item.dig("document_type") == "organisation"
      crumbs << { title: 'Organisations', url: '/government/organisations' }
      if @parent_content_item.dig("title").present?
        crumbs << { title: @parent_content_item.dig("title"), url: @parent_content_item.dig("base_path") }
      end
    end

    if @finder_name.present?
      crumbs << { title: @finder_name, is_current_page: true }
    end

    crumbs
  end
end
