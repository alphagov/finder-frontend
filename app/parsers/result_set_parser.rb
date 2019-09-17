module ResultSetParser
  def self.parse(search_results)
    results = search_results.fetch("results")
    start = search_results.fetch("start", 0)
    total = search_results.fetch("total")
    documents = results.each_with_index.map { |document, index| Document.new(document, index + 1) }

    ResultSet.new(
      documents,
      start,
      total,
    )
  end
end
