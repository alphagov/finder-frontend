class Document
  attr_reader :title, :url, :metadata

  def initialize(attrs)
    @title = attrs[:title]
    @url = attrs[:url]
    @metadata = attrs[:metadata]
  end

  def to_partial_path
    'document'
  end
end
