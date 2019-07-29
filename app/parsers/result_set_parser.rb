module ResultSetParser
  def self.parse(results, total, finder_presenter)
    documents = results.map { |document| Document.new(document, finder_presenter) }

    ResultSet.new(
      documents,
      total,
    )
  end
end
