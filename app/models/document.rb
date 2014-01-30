class Document
  attr_reader :title, :url, :metadata

  def self.from_hash(document_hash)
    self.new({
      title: document_hash['title'],
      url: document_hash['url'],
      metadata: document_hash['metadata'].map(&:symbolize_keys)
    })
  end

  def initialize(attrs)
    @title = attrs[:title]
    @url = attrs[:url]
    @metadata = attrs[:metadata]
  end

  def to_partial_path
    'document'
  end
end
