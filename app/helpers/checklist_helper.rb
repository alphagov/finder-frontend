module ChecklistHelper
  def next_viewable_page(page, questions)
    question_index = page - 1
    while question_index <= questions.length
      break if questions[question_index].show?(criteria_keys)

      question_index += 1
    end
    question_index + 1
  end

  def format_criteria_list(criteria)
    criteria.map { |criterion| { readable_text: criterion.text } }
  end

  def format_action_sections(actions)
    [
      {
        heading: "Some category",
        actions: actions
      }
    ]
  end
end
