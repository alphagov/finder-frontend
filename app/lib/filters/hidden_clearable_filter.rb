module Filters
  class HiddenClearableFilter < Filter
  private

    def value
      params
    end
  end
end
