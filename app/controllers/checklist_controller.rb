class ChecklistController < ApplicationController
  layout "finder_layout"

  def show
    if redirect_to_results?
      redirect_to_result_page
    else
      @checklist_questions = ChecklistQuestionsPresenter.new(page, filtered_params, questions)
      if @checklist_questions.get_next_page != page
        redirect_to find_brexit_guidance_path(filtered_params.merge(page: @checklist_questions.get_next_page))
      else
        render "checklist/show"
      end
    end
  end

  def results
    @checklist = ChecklistAnswers.new(request.query_parameters.except(:page))
    render "checklist/results"
  end

private

  def qa_config
    @qa_config ||= YAML.load_file("lib/find_brexit_guidance.yaml")
  end

  ###
  # Page title and breadcrumbs
  ###

  def title
    qa_config["title"]
  end
  helper_method :title

  def breadcrumbs
    [{ title: "Home", url: "/" }]
  end
  helper_method :breadcrumbs

  ###
  # Questions
  ###

  def questions
    @questions ||= begin
      qa_config["questions"].map do |question|
        ChecklistQuestion.new(question)
      end
    end
  end

  ###
  # Current page
  ###

  def page
    @page ||= begin
      params.permit(:page)
      params[:page].to_i.clamp(1, questions.length + 1)
    end
  end

  ###
  # Navigation
  ###
  def next_page
    page + 1
  end
  helper_method :next_page

  def next_page_url
    request.path
  end
  helper_method :next_page_url

  def skip_link_url
    page_number = { page: next_page }
    next_page_url + "?" + filtered_params.merge(page_number).to_query
  end
  helper_method :skip_link_url

  ###
  # Redirect
  ###

  def redirect_to_results?
    page == questions.length + 1
  end

  def redirect_to_result_page
    redirect_to find_brexit_guidance_results_path(filtered_params)
  end

  def filtered_params
    request.query_parameters.except(:page)
  end
  helper_method :filtered_params
end
