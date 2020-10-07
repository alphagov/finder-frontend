require_relative "../lib/oidc_client.rb"

class BrexitCheckerController < ApplicationController
  include BrexitCheckerHelper

  SUBSCRIBER_LIST_GROUP_ID = "5a7c11f2-e737-4531-a0bc-b5f707046607".freeze

  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action do
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  before_action :check_accounts_enabled, only: %i[save_results saved_results edit_saved_results]

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
    @account_information = if logged_in? && accounts_enabled?
                             "Logged in. <a class=\"govuk-link\" href=\"#{transition_checker_end_session_path}\">Log out.</a>"
                           elsif accounts_enabled?
                             "Not logged in. <a class=\"govuk-link\" href=\"#{transition_checker_new_session_path}\">Login.</a>"
                           else
                             ""
                           end

    all_actions = BrexitChecker::Action.load_all
    @criteria = BrexitChecker::Criterion.load_by(criteria_keys)
    @actions = filter_actions(all_actions, criteria_keys)
    @audience_actions = @actions.group_by(&:audience)
    @business_results = grouped_results.populate_business_groups
    @citizen_results_groups = grouped_results.populate_citizen_groups
  end

  def email_signup; end

  def confirm_email_signup
    request = Services.email_alert_api.find_or_create_subscriber_list_cached(subscriber_list_options)
    subscriber_list_slug = request.dig("subscriber_list", "slug")

    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

  def save_results; end

  def saved_results
    redirect_to transition_checker_new_session_path(redirect_path: transition_checker_saved_results_path) and return unless logged_in?

    if results_from_account.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_results_path(c: results_from_account)
    end
  end

  def edit_saved_results
    redirect_to transition_checker_new_session_path(redirect_path: transition_checker_edit_saved_results_path) and return unless logged_in?

    if results_from_account.empty?
      redirect_to transition_checker_questions_path
    else
      redirect_to transition_checker_questions_path(c: results_from_account, page: 0)
    end
  end

private

  def results_from_account
    @results_from_account ||= begin
      Array(
        update_session_tokens(
          oidc.get_checker_attribute(
            access_token: session[:access_token],
            refresh_token: session[:refresh_token],
          ),
        ),
      )
                              rescue OidcClient::OAuthFailure
                                # this means the refresh token has been revoked or the
                                # accounts services are down
                                logout!
                                []
    end
  end

  def grouped_results
    @grouped_results ||= BrexitChecker::Results::GroupByAudience.new(@audience_actions, @criteria)
  end

  def update_session_tokens(result)
    session[:access_token] = result[:access_token]
    session[:refresh_token] = result[:refresh_token]
    result[:result]
  end

  def subscriber_list_options
    path = transition_checker_results_path(c: criteria_keys)

    {
      "title" => "Get ready for 2021",
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
