module ResultSetParser
  def self.parse(search_results)
    results = search_results.fetch("results")
    start = search_results.fetch("start", 0)
    total = search_results.fetch("total")
    discovery_engine_attribution_token = search_results.fetch("discovery_engine_attribution_token", nil)
    documents = results.each_with_index.map { |document, index| Document.new(document, index + 1) }

    ResultSet.new(
      documents,
      start,
      total,
      discovery_engine_attribution_token,
    )
  end
end
