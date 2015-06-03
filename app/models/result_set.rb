class ResultSet
  attr_reader :documents, :total, :facets

  def self.get(finder, params)
    ResultSetParser.new(finder).parse(
      FinderFrontend.get_documents(finder, params)
    )
  end

  def initialize(documents, total, facets)
    @documents = documents
    @total = total
    @facets = facets
  end
end
