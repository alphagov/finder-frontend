class BrexitChecker::ResultsAudiences
  class << self
    def populate_business_groups(audience_actions, selected_criteria)
      return {} if audience_actions.blank? || selected_criteria.blank?

      {
        actions: audience_actions,
        criteria: filter_criteria_by_actions(audience_actions, selected_criteria),
      }
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
