module Filters
  class HiddenClearableFilter < Filter
    def value
      params
    end
  end
end
