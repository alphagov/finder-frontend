class ChecklistController < ApplicationController
  layout "finder_layout"

  def show
    if redirect_to_results?
      redirect_to_result_page
    else
      render "checklist/show"
    end
  end

private

  def qa_config
    @qa_config ||= YAML.load_file("lib/#{request.path.tr('-', '_')}.yaml")
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
    @questions ||= qa_config["questions"]
  end
  helper_method :question

  ###
  # Current page
  ###

  def page
    params.permit(:page)
    params[:page].to_i.clamp(1, questions.length + 1)
  end

  def current_question
    current_question = questions[page - 1]
    {
      "key" => current_question["key"],
      "question" => current_question["question"],
      "description" => current_question["description"],
      "hint_title" => current_question["hint_title"],
      "hint_text" => current_question["hint_text"],
      "options" => current_question["options"],
      "type" => current_question["question_type"]
    }
  end
  helper_method :current_question

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
  # Question types
  ###

  def question_type
    @question_type ||= current_question["type"]
  end

  def single_wrapped_question?
    question_type == "single_wrapped"
  end
  helper_method :single_wrapped_question?

  def multiple_grouped_question?
    question_type == "multiple_grouped"
  end
  helper_method :multiple_grouped_question?

  def multiple_question?
    question_type == "multiple"
  end
  helper_method :multiple_question?

  ###
  # Options
  ###

  def options
    allowed_values = current_question["options"]
    allowed_values.map do |option|
      checked = filtered_params[current_question["key"]].present? && filtered_params[current_question["key"]].include?(option["value"])
      { label: option["label"], text: option["label"], value: option["value"], checked: checked }
    end
  end
  helper_method :options

  ###
  # Redirect
  ###

  def redirect_to_results?
    page == questions.length + 1
  end

  def redirect_to_result_page
    render "checklist/action_list"
  end

  def filtered_params
    request.query_parameters.except(:page)
  end
  helper_method :filtered_params
end
