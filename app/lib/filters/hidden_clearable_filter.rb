# typed: true
module Filters
  class HiddenClearableFilter < Filter
  private # rubocop:disable Layout/IndentationWidth

    def value
      params
    end
  end
end
