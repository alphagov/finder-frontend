module AbTest::SearchAutocompleteAbTestable
  def search_autocomplete_ab_test
    GovukAbTesting::AbTest.new(
      "SearchAutocomplete",
      allowed_variants: [
        "A", # No autocomplete
        "B", # Autocomplete
        "Z", # No autocomplete
      ],
      control_variant: "Z",
    )
  end

  def set_search_autocomplete_ab_test_requested_variant
    @requested_variant = search_autocomplete_ab_test.requested_variant(request.headers)
    @requested_variant.configure_response(response)
  end

  def use_autocomplete?
    @requested_variant&.variant?("B")
  end
end
