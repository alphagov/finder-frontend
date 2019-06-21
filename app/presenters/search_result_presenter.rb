class SearchResultPresenter
  delegate :title,
           :summary,
           :is_historic,
           :show_metadata,
           :government_name,
           :format,
           :es_score,
           to: :search_result

  def initialize(search_result, metadata)
    @search_result = search_result
    @metadata = metadata
  end

  def to_hash
    {
      title: title,
      link: link,
      summary: summary,
      is_historic: is_historic,
      government_name: government_name,
      metadata: metadata,
      show_metadata: show_metadata,
      format: format,
      es_score: es_score,
    }
  end

  def link
    search_result.path
  end

private

  attr_reader :search_result, :metadata
end
