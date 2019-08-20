module ResultSetParser
  def self.parse(results, total, finder_presenter)
    documents = results.each_with_index.map { |document, index| Document.new(document, finder_presenter, index + 1) }

    ResultSet.new(
      documents,
      total,
    )
  end
end
