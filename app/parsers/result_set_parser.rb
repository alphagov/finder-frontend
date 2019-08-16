module ResultSetParser
  def self.parse(results, total)
    documents = results.each_with_index.map { |document, index| Document.new(document, index + 1) }

    ResultSet.new(
      documents,
      total,
    )
  end
end
