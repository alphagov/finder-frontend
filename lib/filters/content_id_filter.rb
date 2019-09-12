module Filters
  class ContentIdFilter < Filter
  private # rubocop:disable Layout/IndentationWidth

    def value
      @value ||= Array(params).map(&method(:content_id_for))
    end

    def content_id_for(value)
      content_id_map[value]
    end

    def content_id_map
      @content_id_map = allowed_values.to_h { |v| [v["value"], v["content_id"]] }
    end

    def allowed_values
      facet["allowed_values"]
    end
  end
end
