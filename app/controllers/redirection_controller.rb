class RedirectionController < ApplicationController
  def redirect_brexit
    redirect_to(finder_path(params[:slug], params: brexit_topic_and_other_params))
  end

  def redirect_covid
    redirect_to(finder_path(params[:slug], params: covid_topic_and_other_params))
  end

  def redirect_latest
    redirect_params = params.slice(:departments, :topical_events, :world_locations)
                            .permit(departments: [], topical_events: [], world_locations: [])
                            .transform_keys { |k| k == "departments" ? "organisations" : k }
                            .compact

    redirect_to(finder_path("search/all", params: { order: "updated-newest" }.merge(redirect_params)))
  end

  def redirect_consultations
    topics = {}
    topics["level_one_taxon"] = params[:topics] if params[:topics]
    topics["level_two_taxon"] = params[:subtaxons] if params[:subtaxons]

    redirect_params = params.merge(topics)
                            .slice(:departments, :level_one_taxon, :level_two_taxon, :world_locations, :content_store_document_type)
                            .permit(:level_one_taxon, :level_two_taxon, departments: [], world_locations: [], content_store_document_type: [])
                            .transform_keys { |k| k == "departments" ? "organisations" : k }
                            .compact
    redirect_params[:content_store_document_type] = %w[open_consultations closed_consultations]

    redirect_to(finder_path("search/policy-papers-and-consultations", params: { order: "updated-newest" }.merge(redirect_params)))
  end

  def redirect_statistics_announcements
    redirect_to(finder_path("search/research-and-statistics", params: statistics_announcements_topic_and_other_params))
  end

  def advanced_search
    conversion_hash =
      {
        "services" => "services",
        "guidance_and_regulation" => "guidance-and-regulation",
        "news_and_communications" => "news-and-communications",
        "research_and_statistics" => "research-and-statistics",
        "policy_and_engagement" => "policy-papers-and-consultations",
        "transparency" => "transparency-and-freedom-of-information-releases",
      }
    group = conversion_hash[params["group"]]
    error_not_found && return if group.nil?

    topic = params["topic"]
    url_params = if topic.present?
                   registry = Services.registries.all["full_topic_taxonomy"]
                   content_id, = registry.taxonomy.find { |_, hash| hash["base_path"] == topic }
                   { topic: content_id }
                 else
                   {}
                 end
    redirect_to(finder_path("search/#{group}", params: url_params))
  end

private

  def brexit_topic_and_other_params
    {
      keywords: filter_params["keywords"],
      level_one_taxon: ContentItem::BREXIT_CONTENT_ID,
      organisations: filter_params["organisations"],
      people: filter_params["people"],
      public_timestamp: filter_params["public_timestamp"],
      roles: filter_params["roles"],
      world_locations: filter_params["world_locations"],
    }.compact
  end

  def covid_topic_and_other_params
    {
      keywords: filter_params["keywords"],
      level_one_taxon: "5b7b9532-a775-4bd2-a3aa-6ce380184b6c",
      organisations: filter_params["organisations"],
      people: filter_params["people"],
      public_timestamp: filter_params["public_timestamp"],
      roles: filter_params["roles"],
      world_locations: filter_params["world_locations"],
    }.compact
  end

  def statistics_announcements_topic_and_other_params
    {
      content_store_document_type: "upcoming_statistics",
      keywords: filter_params["keywords"],
      level_one_taxon: filter_params["topics"],
      organisations: filter_orgs_array(filter_params["organisations"]),
      public_timestamp: {
        from: filter_params["from_date"],
        to: filter_params["to_date"],
      },
    }.compact
  end

  def filter_orgs_array(arr)
    Array(arr).delete_if { |i| i == "all" }
  end
end
