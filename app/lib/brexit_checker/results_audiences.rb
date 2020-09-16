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

        group_key_array(action, selected_criteria).each do |key|
          group = BrexitChecker::Group.find_by(key)
          next if grouped_actions.any? { |actions| actions[:group] == group }

          grouped_actions << {
            group: group,
            actions: actions_for_group(audience_actions, group),
            criteria: criteria_for_group(audience_actions, group, selected_criteria),
          }
        end
        sort_by_priority(grouped_actions)
      end
    end

    def group_key_array(action, selected_criteria)
      multiple_grouping_criteria?(action) ? selected_group(action, selected_criteria) : action.grouping_criteria
    end

    def sort_by_priority(grouped)
      descending = -1
      grouped.sort_by! { |actions| [(actions[:group].priority * descending ), actions[:group].key] }
    end

    def selected_group(action, selected_criteria)
      criteria_keys = selected_criteria.map(&:key)
      action.grouping_criteria.select { |group_key| criteria_keys.include? group_key }
    end

    def all_groups
      @all_groups ||= BrexitChecker::Group.load_all
    end

    def actions_for_group(audience_actions, group)
      audience_actions & group.actions
    end

    def criteria_for_group(audience_actions, group, selected_criteria)
      actions_for_group(audience_actions, group).map do |action|
        if multiple_grouping_criteria?(action)
          filtered_criteria(selected_criteria, action, group.key)
        else
          criteria_for_action(action, selected_criteria)
        end
      end.flatten.uniq
    end

    def filtered_criteria(selected_criteria, action, group_key)
      criteria = criteria_for_action(action, selected_criteria )
      rogue_criteria_keys = (action.grouping_criteria - [group_key])
      criteria.reject { |criterion| rogue_criteria_keys.include? criterion.key }
    end

    def criteria_for_action(action, selected_criteria)
      c = (action.all_criteria & selected_criteria)
      c.flatten.uniq
    end

    def multiple_grouping_criteria?(action)
      action.grouping_criteria.count > 1
    end
  end
end
