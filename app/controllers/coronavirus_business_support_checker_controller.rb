class CoronavirusBusinessSupportCheckerController < ApplicationController
  include CoronavirusBusinessSupportCheckerHelper

  layout "finder_layout"

  before_action do
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def show
    all_questions = BusinessSupportChecker::Question.load_all
    @question_index = next_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      previous_question_index: page,
    )

    @current_question = all_questions[@question_index] if @question_index.present?

    @previous_page = previous_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      current_question_index: page,
    )

    redirect_to cbs_checker_results_path(c: criteria_keys) if @current_question.nil?
  end

  def results
    all_actions = BusinessSupportChecker::Action.load_all
    @criteria = BusinessSupportChecker::Criterion.load_by(criteria_keys)
    @actions = filter_items(all_actions, criteria_keys)
  end

private

  def criteria_keys
    @criteria_keys ||= begin
                         keys = ParamsCleaner.new(params).fetch(:c, [])
                         BusinessSupportChecker::Criteria::Filter.new.call(keys)
                       end
  end
  helper_method :criteria_keys

  def page
    @page ||= ParamsCleaner.new(params).fetch(:page, "0").to_i
  end
end
