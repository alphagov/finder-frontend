module ResultSetParser
  def self.parse(response, finder)

    documents = response['results']
      .map { |document| Document.new(document, finder) }

    ResultSet.new(
      documents,
      response['total']
    )
  end
end
