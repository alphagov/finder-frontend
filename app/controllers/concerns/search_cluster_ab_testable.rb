module SearchClusterABTestable
  CUSTOM_DIMENSION = 42

  def self.included(base)
    base.helper_method :search_cluster_variant
    base.after_action :set_search_cluster_response_header
  end

  # A == use A cluster
  # B == use B cluster
  # anything else = use default cluster
  def search_cluster_test
    @search_cluster_test ||= GovukAbTesting::AbTest.new(
      "SearchClusterQueryABTest",
      dimension: CUSTOM_DIMENSION,
      allowed_variants: %w[Default A B],
      control_variant: "Default",
    )
  end

  def search_cluster_variant
    @search_cluster_variant ||= search_cluster_test.requested_variant(request.headers)
  end

  def search_cluster_ab_params
    if use_default_cluster?
      {}
    else
      { search_cluster_query: use_b_cluster? ? "B" : "A" }
    end
  end

  def set_search_cluster_response_header
    search_cluster_variant.configure_response(response) if search_cluster_test_in_scope?
  end

  def use_default_cluster?
    !(search_cluster_variant.variant?("A") || search_cluster_variant.variant?("B"))
  end

  def use_b_cluster?
    search_cluster_variant.variant? "B"
  end

  def search_cluster_test_in_scope?
    content_item.is_finder? && search_query
  end
end
