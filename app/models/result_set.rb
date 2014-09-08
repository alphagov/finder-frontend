class ResultSet
  attr_reader :documents

  delegate :count, to: :documents

  def self.get(finder_slug, document_type, params)
    ResultSetParser.parse(FinderFrontend.get_documents(finder_slug, document_type, params))
  end

  def initialize(attrs)
    @documents = attrs[:documents]
  end

  def to_partial_path
    'results'
  end
end
