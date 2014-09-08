module ResultSetParser
  def self.parse(results)

    documents = results
      .map { |document_hash| DocumentParser.parse(document_hash) }

    ResultSet.new(
      documents: documents
    )
  end
end
