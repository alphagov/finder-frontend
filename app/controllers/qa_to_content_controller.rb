require 'gds_api/helpers'

# This class currently supports only one question
# If there is a need for multiple questions, this class needs to be modified

class QaToContentController < ApplicationController
  layout "finder_layout"
  include GdsApi::Helpers

  def show
    return error_not_found unless ENV["FINDER_FRONTEND_ENABLE_QA_TO_CONTENT"]

    if params[first_question["id"]].present?
      redirect_to_guidance params[first_question["id"]]
    else
      render 'qa_to_content/show'
    end
  end

private

  def qa_config
    @qa_config ||= YAML.load_file("lib/#{request.path.tr('-', '_')}.yaml")
  end

  def title
    qa_config["title"]
  end
  helper_method :title

  def breadcrumbs
    [{ title: "Home", url: "/" }]
  end
  helper_method :breadcrumbs

  def questions
    @questions ||= qa_config["questions"]
  end

  def first_question
    questions.first
  end
  helper_method :first_question

  def format_options(options)
    options.map do |option|
      return option if option.is_a? String

      { text: option["text"], value: option["value"] }
    end
  end
  helper_method :format_options

  def is_a_permitted_destinations(url)
    found = false
    first_question["options"].each do |option|
      if option["value"] == url
        found = true
        break
      end
    end
    found
  end

  def redirect_to_guidance(url)
    if is_a_permitted_destinations(url)
      redirect_to url
    end
  end
end
