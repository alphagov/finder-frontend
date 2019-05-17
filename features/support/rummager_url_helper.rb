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
    base_search_params.merge(
      'fields' => news_and_communications_search_fields.join(','),
      'filter_content_purpose_supergroup' => 'news_and_communications',
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
    )
  end

  def services_search_params
    base_search_params.merge(
      'fields' => services_search_fields.join(','),
      'filter_content_purpose_supergroup' => 'services',
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
      )
  end

  def policy_papers_params
    base_search_params.merge(
      'fields' => policy_papers_search_fields.join(','),
      'filter_content_purpose_supergroup' => 'policy_and_engagement',
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
      'facet_organisations' => '1500,order:value.title',
      'facet_world_locations' => '1500,order:value.title',
      'count' => 20,
      'order' => '-public_timestamp',
    )
  end

  def all_content_params
    base_search_params.merge(
      'facet_manual' => '1500,order:value.title',
      'facet_organisations' => '1500,order:value.title',
      'facet_people' => '1500,order:value.title',
      'facet_world_locations' => '1500,order:value.title',
      'filter_all_part_of_taxonomy_tree[]' => [nil, nil],
      'fields' => all_content_search_fields.join(','),
      'count' => 20,
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

  def policy_papers_search_fields
    base_search_fields + %w(
      part_of_taxonomy_tree
      content_store_document_type
      organisations
      world_locations
    )
  end

  def research_and_statistics_search_fields
    base_search_fields + %w(
      release_timestamp
      statistics_announcement_state
      display_type
      document_collections
      part_of_taxonomy_tree
      research_and_statistics
      organisations
      world_locations
    )
  end

  def all_content_search_fields
    base_search_fields + %w(
      part_of_taxonomy_tree
      manual
      organisations
      people
      world_locations
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

  def business_readiness_params
    base_search_params.merge(
      "fields" => business_readiness_fields.join(","),
      "filter_facet_groups" => "52435175-82ed-4a04-adef-74c0199d0f46",
    )
  end

  def policies_search_fields
    base_search_fields + %w(
      organisations
    )
  end

  def business_readiness_fields
    base_search_fields + %w(facet_values)
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
      content_purpose_supergroup
      format
    )
  end
end

World(RummagerUrlHelper)
