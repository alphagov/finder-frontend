module Filters
  class CheckboxFilter < Filter
  private # rubocop:disable Layout/IndentationWidth

    def value
      # 'params' for a checkbox should be true or false. the value
      # we send to rummager can be params or a static value provided in
      # the finder content item
      @value ||= params.nil? ? nil : facet["filter_value"] || params
    end
  end
end
