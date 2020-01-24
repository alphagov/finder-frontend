module LearnToRankFeatureFlag
  RANKER_HEADER_NAME = "Govuk-Use-Search-Reranker".freeze

  def ranker_ab_test_params
    ranker_enabled ? { relevance: "B" } : {}
  end

  def ranker_enabled
    ranker_header = request.headers[RANKER_HEADER_NAME] || params[RANKER_HEADER_NAME]
    ranker_header.present? && ranker_header == "true"
  end
end
