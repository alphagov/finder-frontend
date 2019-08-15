class ChecklistController < ApplicationController
  layout "finder_layout"

  def show
    if redirect_to_results?
      redirect_to_result_page
    else
      render "checklist/show"
    end
  end

  def results
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
    redirect_to find_brexit_guidance_results_path + "?" + filtered_params.to_query
  end

  def filtered_params
    request.query_parameters.except(:page)
  end
  helper_method :filtered_params

  ########################################
  #   RESULTS PAGE
  ########################################

  ###
  # Answers
  ###

  def answers
    @answers ||= begin
      answers = []
      questions.each do |question|
        if filtered_params[question["key"]].present?
          question["options"].each do |option|
            if filtered_params[question["key"]].include? option["value"]
              answers.push(
                label: option["label"],
                value: option["value"],
                readable_text: "#{question['readable_pretext']} #{option['readable_text']}"
              )
            end
          end
        end
      end
      answers
    end
  end
  helper_method :answers

  ###
  # Paths
  ###

  def qa_path
    find_brexit_guidance_path + "?" + filtered_params.to_query
  end
  helper_method :qa_path

  def email_signup_path
    find_brexit_guidance_path + "/email-signup?" + filtered_params.to_query
  end
  helper_method :email_signup_path

  def feed_path
    find_brexit_guidance_path + "/feed?" + filtered_params.to_query
  end
  helper_method :feed_path

  ###
  # Search
  ###

  def finder_content_item
    @finder_content_item ||= ContentItem.from_content_store('/find-eu-exit-guidance-business') # THIS NEEDS TO BE UPDATED
  end

  def initialize_search_query(topic_filter = {})
    search_params = filter_params.merge(topic_filter)
    Search::Query.new(
      finder_content_item,
      search_params
    )
  end

  def formatted_topic_search_results(search_results)
    search_results.map do |result|
      {
        link: {
          text: result["title"],
          path: result["link"]
        },
        metadata: { # THIS NEEDS TO BE UPDATED
          due_date: ("Due by 31 October 2019" if result["facet_values"].include? "7283b8e1-840f-49da-967f-c0a512a3f531")
        }
      }
    end
  end

  def topic_search_results
    @topic_search_results ||= begin
      results = []
      qa_config['results_page_config']['topics'].each do |topic|
        topic_query_params = {}
        topic['query_params'].each do |query|
          topic_query_params[query["key"]] = query["value"]
        end
        search_results = initialize_search_query(topic_query_params).search_results
        results.push(
          label: topic["label"],
          guidance: topic["guidance"],
          results: formatted_topic_search_results(search_results["results"])
        )
      end
      results
    end
  end
  helper_method :topic_search_results

  def no_results_text
    qa_config['results_page_config']['no_results_text']
  end
  helper_method :no_results_text
end
