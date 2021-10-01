module AbTests::SearchAutocompleteTestable
  CUSTOM_DIMENSION = 61

  ALLOWED_VARIANTS = %w[A B].freeze

  def search_autocomplete_test
    @search_autocomplete_test ||= GovukAbTesting::AbTest.new(
      "SearchAutocomplete",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: ALLOWED_VARIANTS,
      control_variant: "A",
      )
  end

  def search_autocomplete_variant
    search_autocomplete_test.requested_variant(request.headers)
  end

  def set_search_autocomplete_response
    search_autocomplete_variant.configure_response(response)
  end

  def search_autocomplete_variant_b?
    search_autocomplete_variant.variant?("B")
  end
end
