class BrexitChecker::Results::GroupByAudience
  attr_reader :citizen_actions, :business_actions, :criteria

  def initialize(actions, criteria)
    @citizen_actions = actions["citizen"]
    @business_actions = actions["business"]
    @criteria = criteria
  end

  def populate_business_groups
    return {} if business_actions.blank? || criteria.blank?

    {
      actions: business_actions,
      criteria: business_actions.flat_map(&:all_criteria).uniq & criteria,
    }
  end

  def populate_citizen_groups
    return [] if citizen_actions.blank? || criteria.blank?

    citizen_actions.each_with_object([]) do |action, grouped_actions|
      next if action.grouping_criteria.empty?

      group_key_array(action).each do |key|
        group = BrexitChecker::Group.find_by(key)
        next if grouped_actions.any? { |actions| actions[:group] == group }

        grouped_actions << {
          group: group,
          actions: actions_for_group(group, citizen_actions),
          criteria: criteria_for_group(group, citizen_actions),
        }
      end
      sort_by_priority(grouped_actions)
    end
  end

private

  def group_key_array(action)
    action.multiple_grouping_criteria? ? selected_grouping_criteria(action) : action.grouping_criteria
  end

  def sort_by_priority(grouped)
    descending = -1
    grouped.sort_by! { |actions| [(actions[:group].priority * descending), actions[:group].key] }
  end

  def selected_grouping_criteria(action)
    action.grouping_criteria.select { |group_key| criteria_keys.include? group_key }
  end

  def all_groups
    @all_groups ||= BrexitChecker::Group.load_all
  end

  def actions_for_group(group, actions)
    actions & group.actions
  end

  def criteria_keys
    criteria.map(&:key)
  end

  def criteria_for_group(group, actions)
    actions_for_group(group, actions).map { |action|
      BrexitChecker::Results::CriteriaFilter.call(action, group.key, criteria)
    }.flatten.uniq
  end
end
