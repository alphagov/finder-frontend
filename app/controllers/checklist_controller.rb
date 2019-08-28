class ChecklistController < ApplicationController
  include ChecklistHelper
  layout "finder_layout"

  def show
    @questions = Checklists::Question.load_all
    @page_service = Checklists::PageService.new(questions: @questions,
                                                criteria_keys: criteria_keys,
                                                current_page_from_params: current_page_from_params)

    return redirect_to_result_page if @page_service.redirect_to_results?

    @current_question = @questions[@page_service.current_page]
    render "checklist/show"
  end

  def results
    all_actions = Checklists::Action.load_all
    @criteria = Checklists::Criterion.load_by(criteria_keys)
    @actions = filter_actions(all_actions, criteria_keys)

    render "checklist/results"
  end

private

  ###
  # Redirect
  ###
  def redirect_to_results?
    @page_service.redirect_to_results?
  end

  def redirect_to_result_page
    redirect_to checklist_results_path(filtered_params)
  end

  ###
  # Filtered params
  ###

  def filtered_params
    request.query_parameters.except(:page)
  end
  helper_method :filtered_params

  def criteria_keys
    filtered_params.values.flatten
  end

  ###
  # Breadcrumbs
  ###

  def breadcrumbs
    [{ title: "Home", url: "/" }]
  end
  helper_method :breadcrumbs

  ###
  # Current page
  ###

  def current_page_from_params
    params[:page].to_i
  end

  def skip_link_url
    page_number = { page: @page_service.next_page }
    checklist_questions_path(filtered_params.merge(page_number))
  end
  helper_method :skip_link_url
end
