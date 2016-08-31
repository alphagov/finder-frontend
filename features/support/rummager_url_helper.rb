module RummagerUrlHelper
  def rummager_url(params)
    "#{Plek.current.find('search')}/search.json?#{params.to_query}"
  end

  def mosw_search_params
    base_search_params.merge(
      "fields" => mosw_search_fields.join(","),
      "filter_document_type" => "mosw_report",
    )
  end

  def mosw_search_fields
    base_search_fields + %w(
      walk_type
      place_of_origin
      date_of_introduction
      creator
    )
  end

  def policy_search_params
    base_search_params.merge(
      "fields" => policy_search_fields.join(","),
      "filter_policies" => ["benefits-reform"],
    )
  end

  def policy_search_fields
    base_search_fields + %w(
      is_historic
      government_name
      organisations
      display_type
    )
  end

  def cma_case_search_params
    base_search_params.merge(
      "fields" => cma_case_search_fields.join(","),
      "filter_document_type" => "cma_case",
    )
  end

  def cma_case_search_fields
    base_search_fields + %w(
      case_type
      case_state
      market_sector
      outcome_type
      opened_date
      closed_date
    )
  end

  def policies_search_params
    base_search_params.merge(
      "fields" => policies_search_fields.join(","),
      "filter_document_type" => "policy",
    )
  end

  def policies_search_fields
    base_search_fields + %w(
      organisations
    )
  end

  def base_search_params
    {
      "count" => "1000",
      "start" => "0",
    }
  end

  def base_search_fields
    %w(
      title
      link
      description
      public_timestamp
    )
  end
end

World(RummagerUrlHelper)
