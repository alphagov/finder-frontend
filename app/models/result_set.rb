class ResultSet
  attr_reader :documents, :start, :total

  def initialize(documents, start, total)
    @documents = documents
    @start = start
    @total = total
  end
end
