class TranslateContentPurposeFields
  def initialize(query)
    @query = Hash(query).stringify_keys
  end

  def call
    translate_fields_with_prefix('aggregate')
    translate_fields_with_prefix('filter')
    translate_fields_with_prefix('reject')

    @query if @query.present?
  end

private

  def translate_fields_with_prefix(prefix)
    document_types = Array(content_store_document_types(prefix))
    document_types += Array(subgroup_document_types(prefix) || supergroup_document_types(prefix))

    @query.delete("#{prefix}_content_purpose_subgroup")
    @query.delete("#{prefix}_content_purpose_supergroup")

    if document_types.present?
      @query["#{prefix}_content_store_document_type"] = document_types.uniq.sort
    end
  end

  def content_store_document_types(prefix)
    key = "#{prefix}_content_store_document_type"
    @query.delete(key)
  end

  def subgroup_document_types(prefix)
    key = "#{prefix}_content_purpose_subgroup"
    value = @query[key]

    GovukDocumentTypes.subgroup_document_types(*value) if value.present?
  end

  def supergroup_document_types(prefix)
    key = "#{prefix}_content_purpose_supergroup"
    value = @query[key]

    GovukDocumentTypes.supergroup_document_types(*value) if value.present?
  end
end
