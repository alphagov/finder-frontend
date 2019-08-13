# This class currently supports only one question
# If there is a need for multiple questions, this class needs to be modified

class ActionListController < ApplicationController
  layout "finder_layout"

  def show
    render "action_list/show"
  end

private

  def title
    "Prepare for Brexit action list"
  end
  helper_method :title

  def breadcrumbs
    [
      { title: "Home", url: "/" },
      { title: "Prepare for Brexit", url: qa_path }
    ]
  end
  helper_method :breadcrumbs

  ###
  # Q&A
  ###
  def qa_config
    @qa_config ||= YAML.load_file("lib/#{request.path.tr('-', '_').chomp('/actions')}.yaml")
  end

  def questions
    @questions ||= qa_config["questions"]
  end

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

  def filtered_params
    request.query_parameters.except(:page)
  end

  def qa_path
    prepare_everyone_uk_leaving_eu_path + "?" + filtered_params.to_query
  end
  helper_method :qa_path

  def email_signup_path
    qa_config['email_alerts_base_path'] + "?" + filtered_params.to_query
  end
  helper_method :email_signup_path

  def feed_path
    qa_config['feed_base_path'] + "?" + filtered_params.to_query
  end
  helper_method :feed_path
end
