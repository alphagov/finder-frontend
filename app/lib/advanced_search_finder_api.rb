class AdvancedSearchFinderApi < FinderApi
  GROUP_SEARCH_FILTER = "group".freeze
  SUBGROUP_SEARCH_FILTER = "subgroup".freeze
  TAXON_SEARCH_FILTER = "topic".freeze

  attr_reader :content_item

  def content_item_with_search_results
    raise_on_missing_taxon_param

    filter_params[TAXON_SEARCH_FILTER] = taxon["content_id"] if taxon
    content_item = fetch_content_item
    search_response = fetch_search_response(content_item)
    content_item = augment_content_item_links_with_taxon(content_item, taxon)
    augment_content_item_with_results(content_item, search_response)
  end

  def taxon
    @taxon ||= Services.content_store.content_item(filter_params[TAXON_SEARCH_FILTER])
  rescue GdsApi::HTTPNotFound
    raise_on_missing_taxon_at_path
  end

private

  def augment_content_item_links_with_taxon(content_item, taxon)
    content_item["links"]["taxons"] = [taxon]
    content_item
  end

  def augment_facets_with_dynamic_values(content_item, _)
    augment_facets_with_dynamic_subgroups(content_item) if supergroups.any?
  end

  def augment_facets_with_dynamic_subgroups(content_item)
    subgroups = supergroups.map(&:subgroups_as_hash).flatten
    facet = find_facet(content_item, SUBGROUP_SEARCH_FILTER)
    return unless facet
    facet["allowed_values"] = subgroups
    facet["type"] = "hidden" if subgroups.size < 2
  end

  def supergroups
    Supergroups.lookup(filter_params[GROUP_SEARCH_FILTER])
  end

  def find_facet(content_item, key)
    content_item["details"]["facets"].find { |f| f["key"] == key }
  end

  def raise_on_missing_taxon_at_path
    raise_taxon_not_found("No taxon found for path #{filter_params[TAXON_SEARCH_FILTER]}")
  end

  def raise_on_missing_taxon_param
    unless filter_params.has_key?(TAXON_SEARCH_FILTER)
      raise_taxon_not_found("#{TAXON_SEARCH_FILTER} param not present")
    end
  end

  def raise_taxon_not_found(msg = nil)
    raise TaxonNotFound.new(msg)
  end

  class TaxonNotFound < StandardError; end
end
