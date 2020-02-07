class BrexitCheckerController < ApplicationController
  include BrexitCheckerHelper

  SUBSCRIBER_LIST_GROUP_ID = "5a7c11f2-e737-4531-a0bc-b5f707046607".freeze

  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action do
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def show
    all_questions = BrexitChecker::Question.load_all
    @question_index = next_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      previous_question_index: page,
    )

    @business_sectors = load_business_sectors

    @current_question = all_questions[@question_index] if @question_index.present?

    @previous_page = previous_question_index(
      all_questions: all_questions,
      criteria_keys: criteria_keys,
      current_question_index: page,
    )

    redirect_to transition_checker_results_path(c: criteria_keys) if @current_question.nil?
  end

  def results
    all_actions = BrexitChecker::Action.load_all
    @criteria = BrexitChecker::Criterion.load_by(criteria_keys)
    @actions = filter_items(all_actions, criteria_keys)
    audience_actions = @actions.group_by(&:audience)
    @business_results = BrexitChecker::ResultsAudiences.populate_business_groups(audience_actions["business"], @criteria)
    @citizen_results_groups = BrexitChecker::ResultsAudiences.populate_citizen_groups(audience_actions["citizen"], @criteria)
  end

  def email_signup; end

  def confirm_email_signup
    request = Services.email_alert_api.find_or_create_subscriber_list_cached(subscriber_list_options)
    subscriber_list_slug = request.dig("subscriber_list", "slug")

    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

private

  def load_business_sectors
    file = File.read('config/locales/en/brexit_checker/business_sectors.json')
    JSON.parse(file)
  end

  def subscriber_list_options
    path = transition_checker_results_path(c: criteria_keys)

    {
      "title" => "How to prepare for a no deal Brexit",
      "description" => "[You can view a copy of your results on GOV.UK.](#{Plek.new.website_root}#{path})",
      "group_id" => SUBSCRIBER_LIST_GROUP_ID,
      "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
      "url" => path,
    }
  end

  def criteria_keys
    @criteria_keys ||= begin
                         keys = ParamsCleaner.new(params).fetch(:c, [])
                         BrexitChecker::Criteria::Filter.new.call(keys)
                       end
  end
  helper_method :criteria_keys

  def page
    @page ||= ParamsCleaner.new(params).fetch(:page, "0").to_i
  end
end
