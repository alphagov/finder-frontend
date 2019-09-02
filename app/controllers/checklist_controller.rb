class ChecklistController < ApplicationController
  include ChecklistHelper
  layout "finder_layout"

  protect_from_forgery except: :confirm_email_signup

  before_action do
    expires_in(30.minutes, public: true) unless Rails.env.development?
  end

  def show
    @questions = Checklists::Question.load_all
    @page_service = Checklists::PageService.new(questions: @questions,
                                                criteria_keys: criteria_keys,
                                                current_page_from_params: params[:page].to_i)

    if @page_service.redirect_to_results?
      redirect_to checklist_results_path(c: criteria_keys)
    else
      @current_question = @questions[@page_service.current_page]
    end
  end

  def results
    all_actions = Checklists::Action.load_all
    @criteria = Checklists::Criterion.load_by(criteria_keys)
    @actions = filter_actions(all_actions, criteria_keys)
  end

  def email_signup; end

  def confirm_email_signup
    request = Services.email_alert_api.find_or_create_subscriber_list_cached(subscriber_list_options)
    subscriber_list_slug = request.dig("subscriber_list", "slug")

    redirect_to email_alert_frontend_signup_path(topic_id: subscriber_list_slug)
  end

private

  def subscriber_list_options
    path = checklist_results_path(c: criteria_keys)

    {
      "title" => "Your Get ready for Brexit results",
      "slug" => "brexit-checklist-#{criteria_keys.sort.join('-')}",
      "description" => "[You can view a copy of your Brexit tool results](#{Plek.new.website_root}#{path}) on GOV.UK.",
      "tags" => { "brexit_checklist_criteria" => { "any" => criteria_keys } },
      "url" => path,
    }
  end

  def criteria_keys
    return [] unless params[:c].is_a? Array

    params[:c].select { |k| k =~ /[a-z\-]+/ }
  end
  helper_method :criteria_keys
end
