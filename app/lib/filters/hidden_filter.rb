# typed: true
module Filters
  class HiddenFilter < Filter
  private # rubocop:disable Layout/IndentationWidth

    def value
      params
    end
  end
end
