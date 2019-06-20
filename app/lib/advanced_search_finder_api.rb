# typed: true
class AdvancedSearchFinderApi < FinderApi
  include AdvancedSearchParams

  def content_item_with_search_results
    raise_on_missing_taxon_param

    filter_params[TAXON_SEARCH_FILTER] = taxon["content_id"] if taxon
    augment_content_item_with_results
    augment_content_item_links_with_taxon(content_item, taxon)
    content_item
  end

  def taxon
    @taxon ||= Services.cached_content_item(filter_params[TAXON_SEARCH_FILTER])
  rescue GdsApi::HTTPNotFound
    raise_on_missing_taxon_at_path
  end

private

  def augment_content_item_links_with_taxon(content_item, taxon)
    content_item["links"]["taxons"] = [taxon]
  end

  def augment_content_item_with_results
    content_item['details']['results'] = search_results.fetch("results")
    augment_facets_with_dynamic_values(content_item)
  end

  def augment_facets_with_dynamic_values(content_item_hash)
    augment_facets_with_dynamic_subgroups(content_item_hash) if supergroups.any?
  end

  def augment_facets_with_dynamic_subgroups(content_item_hash)
    subgroups = supergroups.map(&:subgroups_as_hash).flatten
    facet = find_facet(content_item_hash, SUBGROUP_SEARCH_FILTER)
    return unless facet

    facet["allowed_values"] = subgroups
    facet["type"] = "hidden" if subgroups.size < 2
  end

  def supergroups
    Supergroups.lookup(filter_params[GROUP_SEARCH_FILTER])
  end

  def find_facet(content_item_hash, key)
    content_item_hash["details"]["facets"].find { |f| f["key"] == key }
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

  def query_builder_class
    AdvancedSearchQueryBuilder
  end

  class TaxonNotFound < StandardError; end
end
