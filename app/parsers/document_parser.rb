module DocumentParser
  def self.parse(document_hash)
    Document.new({
      title: document_hash['title'],
      url: document_hash['url'],
      metadata: document_hash['metadata'].map(&:symbolize_keys)
    })
  end
end
