class BrexitCheckerController < ApplicationController
  include BrexitCheckerHelper
  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action do
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def show
    @questions = BrexitChecker::Question.load_all
    @page_service = BrexitChecker::PageService.new(questions: @questions,
                                                criteria_keys: criteria_keys,
                                                current_page_from_params: page)

    if @page_service.redirect_to_results?
      redirect_to brexit_checker_results_path(c: criteria_keys)
    else
      @current_question = @questions[@page_service.current_page]
    end
  end

  def results
    all_actions = BrexitChecker::Action.load_all
    @criteria = BrexitChecker::Criterion.load_by(criteria_keys)
    @actions = filter_items(all_actions, criteria_keys)
  end

  def email_signup; end

  def confirm_email_signup
    request = Services.email_alert_api.find_or_create_subscriber_list_cached(subscriber_list_options)
    subscriber_list_slug = request.dig("subscriber_list", "slug")

    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

private

  def subscriber_list_options
    path = brexit_checker_results_path(c: criteria_keys)

    {
      "title" => "Your Get ready for Brexit results",
      "description" => "[You can view a copy of your results on GOV.UK.](#{Plek.new.website_root}#{path})",
      "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
      "url" => path,
    }
  end

  def criteria_keys
    @criteria_keys ||= ParamsCleaner.new(params).fetch(:c, [])
  end
  helper_method :criteria_keys

  def page
    @page ||= ParamsCleaner.new(params).fetch(:page, "0").to_i
  end
end
