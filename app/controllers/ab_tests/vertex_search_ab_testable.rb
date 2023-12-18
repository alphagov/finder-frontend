module AbTests::VertexSearchAbTestable
  def vertex_search_ab_test
    GovukAbTesting::AbTest.new(
      "VertexSearch",
      dimension: 41,
      allowed_variants: %w[A B Z],
      control_variant: "Z",
    )
  end

  def page_under_test?
    request.path.include?("/search/all")
  end

  def set_requested_variant
    @requested_variant = vertex_search_ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end

  def ab_params
    { vertex: @requested_variant.variant_name }
  end
end
