class ChecklistQuestionsPresenter
  attr_reader :page, :filtered_params, :questions

  def initialize(page, filtered_params, questions)
    @page = page
    @filtered_params = filtered_params
    @questions = questions
  end

  def current_question
    questions[get_next_page - 1]
  end

  def get_next_page
    @get_next_page ||= begin
      question_index = page - 1
      while question_index <= questions.length
        break if questions[question_index].show?(filtered_params)

        question_index += 1
      end
      question_index + 1
    end
  end
end
