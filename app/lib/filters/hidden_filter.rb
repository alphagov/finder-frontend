module Filters
  class HiddenFilter < Filter
  private

    def value
      params
    end
  end
end
