module RummagerUrlHelper
  def rummager_url(params)
    "#{Plek.find('search-api')}/search.json?#{params.to_query}"
  end

  def mosw_search_params
    base_search_params.merge(
      "fields" => mosw_search_fields.join(","),
      "filter_document_type" => "mosw_report",
    )
  end

  def mosw_search_params_no_facets
    base_search_params.merge(
      "fields" => base_search_fields.join(","),
      "filter_document_type" => "mosw_report",
    )
  end

  def mosw_search_fields
    base_search_fields + %w[
      walk_type
      place_of_origin
      date_of_introduction
      creator
    ]
  end

  def news_and_communications_search_params
    base_search_params.merge(
      "filter_content_purpose_supergroup" => "news_and_communications",
    )
  end

  def services_search_params
    base_search_params.merge(
      "filter_content_purpose_supergroup" => "services",
    )
  end

  def policy_papers_params
    base_search_params.merge(
      "filter_content_purpose_supergroup" => %w[policy_and_engagement],
      "count" => "20",
      "order" => "-public_timestamp",
    )
  end

  def all_content_params
    base_search_params.merge(
      "count" => "20",
    )
  end

  def cma_case_search_params
    base_search_params.merge(
      "fields" => cma_case_search_fields.join(","),
      "filter_document_type" => "cma_case",
    )
  end

  def cma_case_search_fields
    base_search_fields + %w[
      case_type
      case_state
      market_sector
      outcome_type
      opened_date
      closed_date
    ]
  end

  def base_search_params
    {
      "count" => "1500",
      "start" => "0",
      "suggest" => "spelling_with_highlighting",
    }
  end

  def base_search_fields
    %w[
      title
      link
      description_with_highlighting
      public_timestamp
      popularity
      content_purpose_supergroup
      content_store_document_type
      format
      is_historic
      government_name
      content_id
      parts
    ]
  end
end

World(RummagerUrlHelper)
