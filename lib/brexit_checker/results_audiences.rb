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

      BrexitChecker::Group.load_all.each_with_object([]) do |group, result|
        selected_actions = group.actions & audience_actions
        unless selected_actions.empty?
          result << {
            group: group,
            actions: selected_actions,
            criteria: selected_actions.flat_map(&:all_criteria).uniq,
          }
        end
        result
      end
    end
  end
end
