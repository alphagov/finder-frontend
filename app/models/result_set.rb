class ResultSet
  attr_reader :documents, :start, :total, :discovery_engine_attribution_token

  def initialize(documents, start, total, discovery_engine_attribution_token = nil)
    @documents = documents
    @start = start
    @total = total
    @discovery_engine_attribution_token = discovery_engine_attribution_token
  end
end
