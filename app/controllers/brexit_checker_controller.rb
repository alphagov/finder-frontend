class BrexitCheckerController < ApplicationController
  include AccountConcern
  include BrexitCheckerHelper
  include Slimmer::Template

  layout "finder_layout"
  slimmer_template "header_footer_only_old_header"

  protect_from_forgery except: %i[
    confirm_email_signup
    save_results_sign_up
    save_results_apply
  ]

  before_action :enable_caching, only: %i[show email_signup confirm_email_signup results]

  helper_method :subscriber_list_slug

  def show
    all_questions = BrexitChecker::Question.load_all

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

    redirect_to transition_checker_results_path(c: criteria_keys) if @current_question.nil?
  end

  def results
    @presenter = result_presenter
  end

  def email_signup; end

  def confirm_email_signup
    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

  def save_results; end

  def save_results_sign_up
    url = transition_checker_new_session_url(transition_checker_save_results_confirm_path(c: criteria_keys))
    redirect_to("#{url}&register=1")
  end

  def save_results_confirm
    if criteria_keys == @saved_results
      redirect_to transition_checker_results_path(c: criteria_keys)
    elsif @saved_results.nil?
      update_answers_and_email_subscription_in_account_or_reauthenticate(subscriber_list_slug, criteria_keys)
    end
  end

  def save_results_apply
    update_answers_and_email_subscription_in_account_or_reauthenticate(subscriber_list_slug, criteria_keys)
  end

  def saved_results
    if @saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_results_path(c: @saved_results)
    end
  end

  def edit_saved_results
    if @saved_results.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_questions_path(c: @saved_results, page: 0)
    end
  end

private

  def subscriber_list_slug
    @subscriber_list_slug ||= Services.email_alert_api
      .find_or_create_subscriber_list_cached(subscriber_list_options)
      .dig("subscriber_list", "slug")
  end

  def enable_caching
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def subscriber_list_options
    path = transition_checker_results_path(c: criteria_keys)

    {
      "title" => "Brexit checker results",
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

  def result_presenter
    @result_presenter ||= BrexitChecker::Results::ResultPresenter.new(criteria_keys)
  end
end
