module LearningToRankModelsAbTestable
  CUSTOM_DIMENSION = 42
  ALLOWED_VARIANTS = %w(unchanged hippo elephant).freeze

  def self.included(base)
    base.helper_method(:model_variant)
    base.after_action :set_model_response_header
  end

  def learning_to_rank_model_ab_test_params
    return {} if model_variant.variant?("unchanged")

    { mv: model_variant.variant_name }
  end

  def model_test
    @model_test ||= GovukAbTesting::AbTest.new(
      "LearningToRankModelABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: ALLOWED_VARIANTS,
      control_variant: "unchanged",
    )
  end

  def model_variant
    @model_variant ||= model_test.requested_variant(request.headers)
  end

  def set_model_response_header
    model_variant.configure_response(response)
  end
end
