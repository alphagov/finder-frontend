module LearnToRankABTestable
  CUSTOM_DIMENSION = 42

  def self.included(base)
    base.helper_method(
      :learn_to_rank_test_params,
      :learn_to_rank_variant,
      :in_learn_to_rank_scope?,
    )
    base.after_action :set_learn_to_rank_response_header
  end

  def learn_to_rank_test_params
    return {} if learn_to_rank_variant.variant?("A")

    { relevance: learn_to_rank_variant.variant_name }
  end

  def learn_to_rank_test
    @learn_to_rank_test ||= GovukAbTesting::AbTest.new(
      "HideKeywordFacetTagsABTest", # Using HideKeywordFacetTagsABTest intentionally
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A B),
      control_variant: "A",
    )
  end

  def learn_to_rank_variant
    @learn_to_rank_variant ||= learn_to_rank_test.requested_variant(request.headers)
  end

  def set_learn_to_rank_response_header
    learn_to_rank_variant.configure_response(response) if in_learn_to_rank_scope?
  end

  def in_learn_to_rank_scope?
    # Enabled on site search only
    content_item.all_content_finder?
  end
end
