class ChecklistQuestionsPresenter
  attr_reader :page, :filtered_params, :questions

  def initialize(page, filtered_params, questions)
    @page = page
    @filtered_params = filtered_params
    @questions = questions
  end

  def current_question
    current_question = get_question
    {
      "key" => current_question["key"],
      "question" => current_question["question"],
      "description" => current_question["description"],
      "hint_title" => current_question["hint_title"],
      "hint_text" => current_question["hint_text"],
      "options" => current_question["options"],
      "type" => current_question["question_type"]
    }
  end

  def get_next_page
    @get_next_page ||= begin
      question_index = page - 1
      while question_index <= questions.length
        break if show_question(question_index)

        question_index += 1
      end
      question_index + 1
    end
  end

private

  def show_question(index)
    condition = questions[index]["conditionally_show_based_on"]
    return true unless condition.present?

    filtered_params[condition["key"]].include? condition["value"]
  end

  def get_question
    questions[get_next_page - 1]
  end
end
