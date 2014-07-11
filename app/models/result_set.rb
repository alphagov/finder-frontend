class ResultSet
  attr_reader :documents

  delegate :count, to: :documents

  def self.get(slug, params)
    ResultSetParser.parse(FinderFrontend.finder_api.get_documents(slug, params))
  end

  def initialize(attrs)
    @documents = attrs[:documents]
  end

  def to_partial_path
    'results'
  end

  def to_hash
    documents_hash = documents.map do |document|
      {
        title: document.title,
        slug: document.slug,
        metadata: document.metadata,
      }
    end
    documents_hash
  end
end
