class AdvancedSearchResultPresenter < SearchResultPresenter
  def to_hash
    super.merge(
      content_purpose_supergroup: content_purpose_supergroup,
      document_type: document_type,
      organisations: organisations,
      publication_date: publication_date,
      show_metadata: show_metadata?,
    )
  end

  def document_type
    return unless show_metadata?
    search_result.document_type.humanize
  end

  def organisations
    return unless show_metadata?
    search_result.organisations.map { |o| o[:title] }.join(", ")
  end

  def publication_date
    return unless show_metadata?
    metadata.select { |h| h[:label] == "Public timestamp" }.first
  end

  def show_metadata?
    return false if content_purpose_supergroup == "services"
    return false if search_result.document_type == "guide"
    true
  end

private

  def content_purpose_supergroup
    supertypes.fetch('content_purpose_supergroup')
  end
end
