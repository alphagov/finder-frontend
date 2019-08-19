class ChecklistAnswers
  attr_reader :filtered_params

  def initialize(filtered_params)
    @filtered_params = filtered_params
  end

  def topic_search_results
    [
      {
        label: "Some category",
        results: [
          {
            link: {
              text: "Alternative provision",
              path: "/government/publications/alternative-provision"
            },
            metadata: {
              due_date: "12 AUG 2019",
              description: "This is really important",
              additional_guidance: {
                text: "More guidance on brexit",
                path: "/government/publications/behaviour-and-discipline-in-schools-guidance-for-governing-bodies"
              }
            }
          },
          {
            link: {
              text: "Behaviour and discipline in schools: guide for governing bodies",
              path: "/government/publications/behaviour-and-discipline-in-schools-guidance-for-governing-bodies"
            },
            metadata: {
              due_date: "12 SEPT 2019",
              description: "This is something that needs to be done ASAP!!"
            }
          },
        ]
      }
    ]
  end

  # TODO: refactor
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

  def qa_config
    @qa_config ||= YAML.load_file("lib/find_brexit_guidance.yaml")
  end
end
