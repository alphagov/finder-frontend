# typed: true
class AdvancedSearchOrderQueryBuilder < OrderQueryBuilder
  include AdvancedSearchParams

private

  def default_order
    return '-popularity' if sort_by_popularity

    super
  end

  def sort_by_popularity
    %w[services guidance_and_regulation].include? params[GROUP_SEARCH_FILTER]
  end
end
