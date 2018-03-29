class AdvancedSearchQueryBuilder < SearchQueryBuilder
  def base_return_fields
    super + %w(
      content_purpose_supergroup
      content_store_document_type
      organisations
    )
  end
end
