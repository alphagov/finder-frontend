# typed: true
module Filters
  class OfficialDocumentsFilter < RadioFilterForMultipleFields
    def filter_hashes
      Filters::OfficialDocumentsHashes.new.call
    end
  end
end
