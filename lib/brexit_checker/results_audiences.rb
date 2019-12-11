class BrexitChecker::ResultsAudiences
  class << self
    def populate_business_groups(audience_actions, selected_criteria)
      return {} if audience_actions.blank? || selected_criteria.blank?

      {
        actions: audience_actions,
        criteria: filter_criteria_by_actions(audience_actions, selected_criteria),
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
            criteria: filter_criteria_by_actions(actions_in_group, selected_criteria),
          }
        end
      end
      grouped_actions.compact
    end

  private

    def filter_actions_by_group(actions, group_key)
      actions.select { |action| action.grouping_criteria.include?(group_key) }
    end

    def filter_criteria_by_actions(actions, criteria)
      return [] if actions.empty? || criteria.empty?

      action_criteria = actions.flat_map do |action|
        BrexitChecker::Criteria::Extractor.extract(action.criteria).to_a
      end
      criteria_keys = criteria.map(&:key) & action_criteria.uniq
      BrexitChecker::Criterion.load_by(criteria_keys)
    end
  end
end
