module ResultSetParser
  def self.parse(results, start, total)
    documents = results.each_with_index.map { |document, index| Document.new(document, index + 1) }

    ResultSet.new(
      documents,
      start,
      total
    )
  end
end
