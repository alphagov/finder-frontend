module Filters
  class TextFilter < Filter
    def value
      Array(params)
    end
  end
end
