module AbTests::ElasticSearchAaTestable
  def elastic_search_aa_test
    GovukAbTesting::AbTest.new(
      "EsSixPointSeven",
      dimension: 41,
      allowed_variants: %w[A B Z],
      control_variant: "Z",
    )
  end

  def page_under_test?
    request.path.include?("/search/all")
  end

  def set_requested_variant
    @requested_variant = elastic_search_aa_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end
end
