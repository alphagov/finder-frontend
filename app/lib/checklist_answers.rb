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
              public_updated_at: Date.parse("2016-06-27 10:29:44 +0000"),
              document_type: "Statutory guidance"
            }
          },
          {
            link: {
              text: "Behaviour and discipline in schools: guide for governing bodies",
              path: "/government/publications/behaviour-and-discipline-in-schools-guidance-for-governing-bodies"
            },
            metadata: {
              public_updated_at: Date.parse("2015-09-24 16:42:48 +0000"),
              document_type: "Statutory guidance"
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
