class TopicalFacet < SelectFacet
  def allowed_values
    [facet['open_value'], facet['closed_value']]
  end

  def to_partial_path
    "select_facet"
  end
end
