module Filters
  class HiddenFilter < Filter
    def value
      params
    end
  end
end
