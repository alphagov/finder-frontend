# typed: true
class ResultSet
  attr_reader :documents, :total

  def initialize(documents, total)
    @documents = documents
    @total = total
  end
end
