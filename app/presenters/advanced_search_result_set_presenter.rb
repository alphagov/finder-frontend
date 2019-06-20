# typed: true
class AdvancedSearchResultSetPresenter < ResultSetPresenter
  include AdvancedSearchParams

  def documents
    results.each_with_index.map do |result, index|
      metadata = metadata_presenter_class.new(result.metadata).present
      {
        document: AdvancedSearchResultPresenter.new(result, metadata).to_hash,
        document_index: index + 1,
      }
    end
  end
end
