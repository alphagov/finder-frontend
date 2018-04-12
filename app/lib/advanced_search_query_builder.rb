class AdvancedSearchQueryBuilder < SearchQueryBuilder
  include AdvancedSearchParams
  def base_return_fields
    super + %w(
      content_purpose_supergroup
      content_store_document_type
      organisations
    )
  end

  def default_order
    return '-popularity' if sort_by_popularity
    super
  end

  def sort_by_popularity
    %w[services guidance_and_regulation].include? params[GROUP_SEARCH_FILTER]
  end
end
