module TopicSearch
  class QueryBuilder
    def call(search_query)
      {
          count: 10,
          q: search_query,
          fields: %w(taxons title link),
      }
    end
  end
end
