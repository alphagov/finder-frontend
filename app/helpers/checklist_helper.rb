module ChecklistHelper
  def next_viewable_page(page, questions, criteria_keys)
    next_page = (page..questions.length).find do |index|
      questions[index - 1].show?(criteria_keys)
    end
    next_page || questions.length + 1
  end

  def format_criteria_list(criteria)
    criteria.map { |criterion| { readable_text: criterion.text } }
  end

  def format_action_sections(actions)
    action_groups = actions.group_by(&:section)

    action_groups.map do |key, action_group|
      {
        heading: I18n.t("checklists_results.sections.#{key}.heading"),
        actions: action_group
      }
    end
  end

  def filter_actions(actions, criteria_keys)
    actions.select do |action|
      action.applies_to?(criteria_keys)
    end
  end

  def action_guidance_link_text(action)
    prompt = action.guidance_prompt.presence ||
      t("checklists_results.actions.guidance_prompt")

    "#{prompt}: #{action.guidance_text}"
  end
end
