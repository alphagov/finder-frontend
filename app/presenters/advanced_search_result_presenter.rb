# typed: true
class AdvancedSearchResultPresenter < SearchResultPresenter
  def to_hash
    super.merge(
      content_purpose_supergroup: search_result.content_purpose_supergroup,
      document_type: document_type,
      organisations: organisations,
      publication_date: publication_date,
      show_metadata: show_metadata?,
      metadata: metadata_bundle,
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
    return false if search_result.content_purpose_supergroup == "services"
    return false if search_result.document_type == "guide"

    true
  end

  def metadata_bundle
    return unless show_metadata?

    metadata_to_return = Array.new

    if publication_date.is_a?(Hash) && publication_date.has_key?(:label)
      metadata_to_return.push(
        is_date: publication_date[:is_date],
        label: publication_date[:label],
        hide_label: true,
        machine_date: publication_date[:machine_date],
        human_date: publication_date[:human_date],
      )
    end

    if organisations.is_a? String
      metadata_to_return.push(
        is_text: true,
        value: organisations,
        label: 'Organisation',
        hide_label: true,
      )
    end

    if document_type.is_a? String
      metadata_to_return.push(
        is_text: true,
        value: document_type,
        label: 'Document type',
        hide_label: true,
      )
    end

    metadata_to_return
  end
end
