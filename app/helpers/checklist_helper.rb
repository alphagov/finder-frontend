module ChecklistHelper
  def format_criteria_list(criteria)
    criteria.map { |criterion| { readable_text: criterion.text } }
  end

  def format_action_audiences(actions)
    action_groups = actions.group_by(&:audience)
    priority_map = { 'High' => 1, 'Medium' => 2, 'Low' => 3 }

    action_groups.map do |key, action_group|
      {
        heading: I18n.t("checklists_results.audiences.#{key}.heading"),
        actions: action_group.sort_by.with_index do |action, index|
          [priority_map[action.priority], index]
        end
      }
    end
  end

  def filter_actions(actions, criteria_keys)
    actions.select do |action|
      action.applies_to?(criteria_keys)
    end
  end
end
