# typed: true
module ResultSetParser
  def self.parse(results, total, finder)
    documents = results.map { |document| Document.new(document, finder) }

    ResultSet.new(
      documents,
      total,
    )
  end
end
