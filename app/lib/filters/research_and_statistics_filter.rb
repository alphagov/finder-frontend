# typed: true
module Filters
  class ResearchAndStatisticsFilter < RadioFilterForMultipleFields
    def filter_hashes
      Filters::ResearchAndStatsHashes.new.call
    end
  end
end
