class Cid
  include Neo4j::ActiveNode

  property :documentType
  property :contentID
  property :name
  property :description
  property :pagerank
  property :title

  has_many :out, :eligibilities, type: :HAS_ELIGIBILITY, model_class: :Eligibility

  def self.where_not_ineligible(attributes)
    Eligibility.
      all.
      reject { |eligibility| eligibility.ineligible?(attributes) }.
      map(&:cids).
      flatten.
      compact
  end
end
