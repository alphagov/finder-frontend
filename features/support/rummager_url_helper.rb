module RummagerUrlHelper
  def rummager_url(params)
    "#{Plek.current.find('search')}/unified_search.json?#{params.to_query}"
  end

  def default_search_params
    {
      "count" => "1000",
      "fields" => mosw_search_fields.join(","),
      "filter_document_type" => "mosw_report",
    }
  end

  def mosw_search_fields
    %w(
      title
      link
      description
      public_timestamp
      walk_type
      place_of_origin
      date_of_introduction
      creator
    )
  end
end

World(RummagerUrlHelper)
