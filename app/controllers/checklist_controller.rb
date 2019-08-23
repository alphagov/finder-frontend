class ChecklistController < ApplicationController
  include ChecklistHelper
  layout "finder_layout"

  def show
    @questions = Checklists::Question.load_all

    return redirect_to_result_page if redirect_to_results?
    return redirect_to_next_question if redirect_to_next_question?

    @current_question = @questions[page - 1]
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

  def redirect_to_next_question?
    next_viewable_page(page, @questions, criteria_keys) != page
  end

  def redirect_to_next_question
    redirect_to find_brexit_guidance_path(
      filtered_params.merge(page: next_viewable_page(page, @questions, criteria_keys))
    )
  end

  def redirect_to_results?
    page == @questions.length + 1
  end

  def redirect_to_result_page
    redirect_to find_brexit_guidance_results_path(filtered_params)
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

  def page
    @page ||= begin
      params.permit(:page)
      params[:page].to_i.clamp(1, @questions.length + 1)
    end
  end

  ###
  # Navigation
  ###
  def next_page
    page + 1
  end
  helper_method :next_page

  def skip_link_url
    page_number = { page: next_page }
    find_brexit_guidance_path(filtered_params.merge(page_number))
  end
  helper_method :skip_link_url
end
