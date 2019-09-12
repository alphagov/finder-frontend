class BrexitChecker::Criteria::Filter
  def call(selected_criteria)
    loop do
      old_size = selected_criteria.size
      selected_criteria &= possible_criteria(selected_criteria)
      break if selected_criteria.size == old_size
    end

    selected_criteria
  end

private

  def possible_criteria(selected_criteria)
    relevant_questions = BrexitChecker::Question.load_all
      .select { |question| question.show?(selected_criteria) }

    relevant_questions
      .flat_map(&:options)
      .flat_map { |o| filter_option_tree(o, selected_criteria) }
      .map(&:value).compact
  end

  def filter_option_tree(option, selected_criteria)
    return [] unless option.value.blank? ||
      selected_criteria.include?(option.value)

    [option] + option.sub_options.flat_map do |sub_option|
      filter_option_tree(sub_option, selected_criteria)
    end
  end
end
