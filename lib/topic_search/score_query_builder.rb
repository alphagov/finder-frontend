# This class is purely for batching the queries to search api
# returns a hash: { id => { content_pages: results, median_score: 2 } }
class TopicSearch::ScoreQueryBuilder
  attr_reader :scores

  def initialize(query)
    @query = query
  end

  def batch_score(root_taxon)
    @batch_score ||= begin
      ids = content_ids(root_taxon)
      queries = ids.map { |id| request_params(query, id).compact }
      batched_results = fetch_results(queries)
      @scores = ids.map.with_index { |id, index|
        results = batched_results[index]["results"]
        [
          id,
          {
            content_pages: results,
            median_score: median_score(results),
          },
        ]
      }.to_h
    end
  end

private

  attr_reader :query

  def fetch_results(queries)
    queries
      .in_groups_of(3, false)
      .each_with_object([]) { |batch, arr|
        arr << Services.rummager.batch_search(batch)["results"]
      }.flatten
  end

  def content_ids(tree)
    tree.all_descendants.map(&:content_id).compact
  end

  def request_params(query, content_id)
    {
      count: 10,
      filter_part_of_taxonomy_tree: content_id,
      q: query,
      fields: %w(title link),
    }
  end

  def median_score(results)
    scores = results.map { |result| result["es_score"] }.compact
    scores.any? ? scores.median : -1000
  end
end
