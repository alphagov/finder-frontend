# Used by the SearchQueryBuilder to build the `filter` part of the Rummager
# search query. This will determine the documents that are returned from rummager.
class AndFilterQueryBuilder < FilterQueryBuilder
  def call
    filters.select(&:active?).map(&:query_hash)
  end
end
