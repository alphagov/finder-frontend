class TaxonFacet < DropdownSelectFacet
  def allowed_values
    @allowed_values ||= registry_values.unshift(none_selected_value)
  end

  def to_partial_path
    "dropdown_select_facet"
  end

private

  def registry_values
    @registry_values ||= registry.taxonomy_tree.values.map { |v|
      { 'text' => v['title'], 'value' => v['content_id'] }
    }
  end

  def none_selected_value
    { 'text' => 'All topics', 'value' => '' }
  end

  def registry
    Registries::BaseRegistries.new.all['part_of_taxonomy_tree']
  end
end
