module Checklists
  class CriteriaPathService
    def initialize(questions)
      @questions = questions
    end

    def used_criteria(criteria_keys)
      used_questions(criteria_keys).inject([]) do |result, question|
        result + (question.possible_criteria & criteria_keys)
      end
    end

  private

    attr_reader :questions

    def used_questions(criteria_keys, start_page = 0)
      page_service = Checklists::PageService.new(questions: questions,
                                                 criteria_keys: criteria_keys,
                                                 current_page_from_params: start_page)
      return [] if page_service.redirect_to_results?

      Array.wrap(questions[page_service.current_page]) + used_questions(criteria_keys, page_service.next_page)
    end
  end
end
