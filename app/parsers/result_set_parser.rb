module ResultSetParser
  def self.parse(result_set_hash)
    documents = result_set_hash['results'].map { |document_hash| DocumentParser.parse(document_hash) }
    ResultSet.new(
      documents: documents
    )
  end
end
