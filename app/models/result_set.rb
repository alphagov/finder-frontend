class ResultSet
  attr_reader :documents, :document_noun

  delegate :count, to: :documents

  def self.from_hash(result_set_hash)
    documents = result_set_hash['documents'].map { |document_hash| Document.from_hash(document_hash) }
    self.new(documents: documents, document_noun: result_set_hash['document_noun'])
  end

  def self.get(api, params)
    self.from_hash(api.get_result_set(params))
  end

  def initialize(attrs)
    @document_noun = attrs[:document_noun]
    @documents = attrs[:documents]
  end

  def to_partial_path
    'results'
  end
end
