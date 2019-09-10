module BrexitChecker
  class PageService
    attr_reader :current_page

    def initialize(questions:, criteria_keys: [], current_page_from_params: 0)
      @questions = questions
      @criteria_keys = criteria_keys
      @current_page_from_params = current_page_from_params
      @current_page = fetch_page(current_page_from_params: @current_page_from_params, criteria_keys: @criteria_keys)
    end

    def next_page
      current_page && current_page + 1
    end

    def redirect_to_results?
      current_page.nil?
    end

  private

    def fetch_page(current_page_from_params: 0, criteria_keys: [])
      available_questions = @questions[current_page_from_params..] || []
      relative_page_index = available_questions.find_index { |question| question.show?(criteria_keys) }
      relative_page_index && (relative_page_index + current_page_from_params)
    end
  end
end
