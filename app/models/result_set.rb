class ResultSet
  attr_reader :documents, :total

  def self.get(finder_slug, document_type, params)
    ResultSetParser.parse(FinderFrontend.get_documents(finder_slug, document_type, params))
  end

  def initialize(documents, total)
    @documents = documents
    @total = total
  end
end
