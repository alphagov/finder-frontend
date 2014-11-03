module ResultSetParser
  def self.parse(response)

    documents = response['results']
      .map { |document_hash| DocumentParser.parse(document_hash) }

    ResultSet.new(
      documents,
      response['total']
    )
  end
end
