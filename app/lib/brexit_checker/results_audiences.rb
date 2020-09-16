class BrexitChecker::ResultsAudiences
  class << self
    def populate_business_groups(audience_actions, selected_criteria)
      return {} if audience_actions.blank? || selected_criteria.blank?

      {
        actions: audience_actions,
        criteria: audience_actions.flat_map(&:all_criteria).uniq & selected_criteria,
      }
    end

    def populate_citizen_groups(audience_actions, selected_criteria)
      return [] if audience_actions.blank? || selected_criteria.blank?

      audience_actions.each_with_object([]) do |action, grouped_actions|
        next if action.grouping_criteria.empty?

        group_keys =
          multiple_grouping_criteria?(action) ? selected_group(action, selected_criteria) : action.grouping_criteria
        group_keys.each do |key|
          group = BrexitChecker::Group.find_by(key)
          next if grouped_actions.any? { |actions| actions[:group] == group }
          selected_actions = group.actions & audience_actions
          grouped_actions << {
            group: group,
            actions: selected_actions,
            criteria: selected_actions.flat_map(&:all_criteria).uniq & selected_criteria,
          }
        end
        grouped_actions
      end
    end

    def selected_group(action, selected_criteria)
      criteria_keys = selected_criteria.map(&:key)
      action.grouping_criteria.select { |group_key| criteria_keys.include? group_key }
    end

    def all_groups
      @all_groups ||= BrexitChecker::Group.load_all
    end

    def multiple_grouping_criteria?(action)
      action.grouping_criteria.count > 1
    end
  end
end
