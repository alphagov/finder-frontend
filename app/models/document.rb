class Document
  attr_reader :title, :metadata

  def self.from_hash(document_hash)
    self.new({
      title: document_hash['title'],
      metadata: document_hash['metadata'].map(&:symbolize_keys)
    })
  end

  def initialize(attrs)
    @title = attrs[:title]
    @metadata = attrs[:metadata]
  end

  def to_partial_path
    'document'
  end
end
