class ChecklistQuestionsPresenter
  attr_reader :page, :criteria, :questions

  def initialize(page, criteria, questions)
    @page = page
    @criteria = criteria
    @questions = questions
  end

  def current_question
    questions[get_next_page - 1]
  end

  def get_next_page
    @get_next_page ||= begin
      question_index = page - 1
      while question_index <= questions.length
        break if questions[question_index].show?(criteria)

        question_index += 1
      end
      question_index + 1
    end
  end
end
