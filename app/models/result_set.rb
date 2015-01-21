class ResultSet
  attr_reader :documents, :total

  def self.get(finder, params)
    ResultSetParser.parse(FinderFrontend.get_documents(finder, params), finder)
  end

  def initialize(documents, total)
    @documents = documents
    @total = total
  end
end
