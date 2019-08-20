class ChecklistAnswers
  def initialize(filtered_params, actions)
    @filtered_params = filtered_params
    @actions = actions
  end

  def answers
    @answers ||= begin
      answers = []
      qa_config["questions"].each do |question|
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

  def action_sections
    [
      {
        heading: "Some category",
        actions: actions
      }
    ]
  end


private

  attr_reader :filtered_params, :actions

  def qa_config
    @qa_config ||= YAML.load_file("lib/find_brexit_guidance.yaml")
  end
end
