# Used by by Search::QueryBuilder to build the `filter` part of the Rummager
# search query. This will determine the documents that are returned from rummager.
module Search
  class FilterQueryBuilder
    def initialize(facets:, user_params:)
      @facets = facets
      @user_params = user_params
    end

    def call
      filters.select(&:active?).map(&:query_hash).inject({}) do |query, filter_hash|
        query.merge(filter_hash) { |_, v1, v2| Array(v1) + Array(v2) }
      end
    end

  private

    attr_reader :facets, :user_params

    def filters
      facets.select { |f| f["filterable"] }.map { |f| build_filter(f) }
    end

    def build_filter(facet)
      filter_class = {
        "checkbox" => Filters::CheckboxFilter,
        "date" => Filters::DateFilter,
        "hidden" => Filters::HiddenFilter,
        "text" => Filters::TextFilter,
        "dropdown_select" => Filters::DropdownSelectFilter,
        "topical" => Filters::TopicalFilter,
        "taxon" => Filters::TaxonFilter,
        "radio" => Filters::RadioFilter,
        "content_id" => Filters::ContentIdFilter,
        "hidden_clearable" => Filters::HiddenClearableFilter,
        "research_and_statistics" => Filters::ResearchAndStatisticsFilter,
        "official_documents" => Filters::OfficialDocumentsFilter,
      }.fetch(facet["type"])

      filter_class.new(facet, params(facet))
    end

    def params(facet)
      facet_key = facet["key"]
      facet_keys = facet["keys"]

      if facet_keys
        return facet_keys.each_with_object({}) { |key, result_hash|
          result_hash[key] = user_params.fetch(key, nil)
        }
      end

      user_params.fetch(facet_key, nil)
    end
  end
end
