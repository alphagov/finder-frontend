module ResultSetParser
  def self.parse(result_set_hash)
    documents = result_set_hash['documents'].map { |document_hash| DocumentParser.parse(document_hash) }
    ResultSet.new(
      documents: documents,
      document_noun: result_set_hash['document_noun']
    )
  end
end
