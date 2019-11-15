module SpellingSuggestionsABTestable
  CUSTOM_DIMENSION = 42

  def self.included(base)
    base.helper_method(
      :spelling_suggestions_variant,
      :spelling_suggestions_ab_test,
      :in_spelling_suggestions_ab_test_scope?,
    )
    base.after_action :set_spelling_suggestions_response_header
  end

  def spelling_suggestions_ab_test
    return {} if spelling_suggestions_variant.variant?("A")

    { spelling_suggestions: spelling_suggestions_variant.variant_name }
  end

  def spelling_suggestions_test
    @spelling_suggestions_test ||= GovukAbTesting::AbTest.new(
      "SpellingSuggestionsABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A B),
      control_variant: "A",
    )
  end

  def spelling_suggestions_variant
    @spelling_suggestions_variant ||= spelling_suggestions_test.requested_variant(request.headers)
  end

  def set_spelling_suggestions_response_header
    spelling_suggestions_variant.configure_response(response) if in_spelling_suggestions_ab_test_scope?
  end

  def in_spelling_suggestions_ab_test_scope?
    content_item.is_finder?
  end
end
