module FinderTopResultAbTestable
  CUSTOM_DIMENSION = 69

  def self.included(base)
    base.helper_method(
      :finder_top_result_variant,
      :show_top_result?,
    )
    base.after_action :set_finder_top_result_response_header
  end

  def finder_top_result_test
    @finder_top_result_test ||= GovukAbTesting::AbTest.new(
      "FinderAnswerABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w(A B),
      control_variant: "A",
    )
  end

  def finder_top_result_variant
    @finder_top_result_variant ||= finder_top_result_test.requested_variant(request.headers)
  end

  def set_finder_top_result_response_header
    finder_top_result_variant.configure_response(response) if finder_top_result_test_in_scope?
  end

  def finder_top_result_test_in_scope?
    content_item.is_finder? && search_query && finder_presenter.eu_exit_finder?
  end

  def show_top_result?
    finder_top_result_variant.variant?("B")
  end
end
