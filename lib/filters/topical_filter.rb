module Filters
  class TopicalFilter < Filter
  private # rubocop:disable Layout/IndentationWidth

    def value
      @value ||= fetch_value
    end

    def fetch_value
      return nil if params.blank?

      user_has_selected_open = params.include?(facet["open_value"]["value"])
      user_has_selected_closed = params.include?(facet["closed_value"]["value"])

      # with both or neither selected, the filter is not used
      if user_has_selected_open && !user_has_selected_closed
        open_value
      elsif user_has_selected_closed && !user_has_selected_open
        closed_value
      end
    end

    # A thing is open when it ends on a future day
    def open_value
      "from:#{later_than_midnight_today}"
    end

    # A thing becomes closed when it ends today or before
    def closed_value
      "to:#{midnight_today}"
    end

    def midnight_today
      Time.zone.now.beginning_of_day.utc
    end

    def later_than_midnight_today
      Time.zone.now.beginning_of_day.change(sec: 1).utc
    end
  end
end
