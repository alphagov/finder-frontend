module RummagerUrlHelper
  def rummager_url(params)
    query = Rack::Utils.build_nested_query(search: [{ 0 => params }])
    "#{Plek.current.find('search')}/batch_search.json?#{query}"
  end

  def simple_rummager_url(params)
    "#{Plek.current.find('search')}/search.json?#{params.to_query}"
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

  def news_and_communications_search_params
    supergroup_document_types = %w(
      asylum_support_decision
      authored_article
      cma_case
      correspondence
      decision
      drug_safety_update
      employment_appeal_tribunal_decision
      employment_tribunal_decision
      fatality_notice
      government_response
      medical_safety_alert
      news_article
      news_story
      oral_statement
      press_release
      service_standard_report
      speech
      tax_tribunal_decision
      utaac_decision
      world_location_news_article
      world_news_story
      written_statement
    )

    base_search_params.merge(
      'fields' => news_and_communications_search_fields.join(','),
      'filter_content_store_document_type' => supergroup_document_types,
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
    )
  end

  def services_search_params
    supergroup_document_types = %w(
      answer
      calculator
      completed_transaction
      form
      guide
      licence
      local_transaction
      place
      simple_smart_answer
      smart_answer
      step_by_step_nav
      transaction
    )

    base_search_params.merge(
      'fields' => services_search_fields.join(','),
      'filter_content_store_document_type' => supergroup_document_types,
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
      )
  end

  def news_and_communications_search_fields
    base_search_fields + %w(
      part_of_taxonomy_tree
      organisations
      people
      world_locations
    )
  end

  def services_search_fields
    base_search_fields + %w(
      part_of_taxonomy_tree
      organisations
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
      "count" => "1500",
      "start" => "0",
    }
  end

  def base_search_fields
    %w(
      title
      link
      description
      public_timestamp
      popularity
    )
  end
end

World(RummagerUrlHelper)
