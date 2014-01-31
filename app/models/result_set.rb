class ResultSet
  attr_reader :documents, :document_noun

  delegate :count, to: :documents

  def self.get(slug, params)
    ResultSetParser.parse(FinderFrontend.finder_api.get_documents(slug, params))
  end

  def initialize(attrs)
    @document_noun = attrs[:document_noun]
    @documents = attrs[:documents]
  end

  def to_partial_path
    'results'
  end
end
