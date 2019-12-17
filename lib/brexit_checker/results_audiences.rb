class BrexitChecker::ResultsAudiences
  class << self
    def populate_business_groups(audience_actions, selected_criteria)
      return {} if audience_actions.blank? || selected_criteria.blank?

      {
        actions: audience_actions,
        criteria: audience_actions.flat_map(&:all_criteria).uniq,
      }
    end

    def populate_citizen_groups(audience_actions, selected_criteria)
      return [] if audience_actions.blank? || selected_criteria.blank?

      all_possible_groups = BrexitChecker::Group.load_all
      grouped_actions = all_possible_groups.map do |group|
        actions_in_group = filter_actions_by_group(audience_actions, group.key)
        if actions_in_group.empty?
          nil
        else
          {
            group: group,
            actions: actions_in_group,
            criteria: actions_in_group.flat_map(&:all_criteria).uniq,
          }
        end
      end
      grouped_actions.compact
    end

  private

    def filter_actions_by_group(actions, group_key)
      actions.select { |action| action.grouping_criteria.include?(group_key) }
    end
  end
end
