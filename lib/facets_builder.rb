class FacetsBuilder
  def initialize(content_item:, search_results:, value_hash:)
    @content_item = content_item
    @search_results = search_results
    @value_hash = value_hash.stringify_keys
  end

  def facets
    facet_hashes.map do |facet_hash|
      facet_hash_with_allowed_values = facet_hash.merge("allowed_values" => allowed_values(facet_hash))
      build_facet(facet_hash_with_allowed_values)
    end
  end

private

  attr_reader :content_item, :search_results, :value_hash

  def filters_on_brexit_topic?
    @value_hash["topic"] == ContentItem::BREXIT_CONTENT_ID
  end

  def is_related_to_brexit_checkbox?(facet_hash)
    facet_hash["key"] == "related_to_brexit" && facet_hash["filter_value"] == ContentItem::BREXIT_CONTENT_ID
  end

  def facet_hashes
    all_facet_hashes = FacetExtractor.new(content_item).extract
    if filters_on_brexit_topic?
      all_facet_hashes.reject { |facet_hash| is_related_to_brexit_checkbox?(facet_hash) }
    else
      all_facet_hashes
    end
  end

  def build_facet(facet_hash)
    if facet_hash["filterable"]
      case facet_hash["type"]
      when "text", "content_id"
        OptionSelectFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "topical"
        TopicalFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "taxon"
        TaxonFacet.new(facet_hash, value_hash.slice(*facet_hash["keys"]))
      when "date"
        DateFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "hidden"
        HiddenFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "checkbox"
        CheckboxFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "radio"
        RadioFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "hidden_clearable"
        HiddenClearableFacet.new(facet_hash, value_hash[facet_hash["key"]])
      when "research_and_statistics"
        RadioFacetForMultipleFilters.new(facet_hash, value_hash[facet_hash["key"]], ::Filters::ResearchAndStatsHashes.new.call)
      when "official_documents"
        RadioFacetForMultipleFilters.new(facet_hash, value_hash[facet_hash["key"]], ::Filters::OfficialDocumentsHashes.new.call)
      else
        raise ArgumentError.new("Unknown filterable facet type: #{facet_hash['type']}")
      end
    else
      Facet.new(facet_hash)
    end
  end

  def allowed_values(facet_hash)
    return facet_hash["allowed_values"] unless facet_hash["allowed_values"].blank?

    facet_key = facet_hash["key"]
    if registries.all.has_key?(facet_key)
      allowed_values_from_registry(facet_key)
    elsif (facet_details = search_results.dig("facets", facet_key))
      allowed_values_for_facet_details(facet_key, facet_details)
    end
  end

  def allowed_values_for_facet_details(facet_key, facet_details)
    facet_details.fetch("options", {})
      .map { |f| f.fetch("value", {}) }
      .map { |value| present_facet_option(value, facet_key) }
      .reject { |f| f["label"].blank? || f["value"].blank? }
  end

  def allowed_values_from_registry(facet_key)
    registries.all[facet_key].values
      .map { |_, results| present_facet_option(results, facet_key) }
      .reject { |f| f["label"].blank? || f["value"].blank? }
  end

  def present_facet_option(value, facet_key)
    slug = value.fetch("slug", "")
    title = value.fetch("title", find_facet_title_by_slug(slug, facet_key))
    label = generate_label(value, title)

    {
      "label" => label,
      "value" => slug,
    }
  end

  def generate_label(value, title)
    acronym = value.fetch("acronym", "")
    return title if acronym.blank? || acronym == title

    title + " (" + acronym + ")"
  end

  def find_facet_title_by_slug(slug, facet_key)
    registry = registries.all[facet_key]
    return "" if registry.nil?

    item = registry[slug] || {}
    item.fetch("title", "")
  end

  def registries
    @registries ||= Registries::BaseRegistries.new
  end
end
