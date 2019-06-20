# typed: true
class AdvancedSearchQueryBuilder < SearchQueryBuilder
  include AdvancedSearchParams
  def base_return_fields
    super + %w(
      content_purpose_supergroup
      content_store_document_type
      organisations
    )
  end

private

  def order_query_builder_class
    AdvancedSearchOrderQueryBuilder
  end
end
