class Checklists::Question
  attr_reader :key, :text, :description, :hint_title, :hint_text,
              :options, :type, :show_condition

  def initialize(params)
    @key            = params['key']
    @text           = params['question']
    @description    = params['description']
    @hint_title     = params['hint_title']
    @hint_text      = params['hint_text']
    @options        = params['options']
    @type           = params['question_type']
    @show_condition = params['conditionally_show_based_on']
  end

  def show?(filtered_params)
    return true unless show_condition.present?

    filtered_params[show_condition["key"]].include? show_condition["value"]
  end

  def formatted_options(filtered_params)
    options.map do |option|
      checked = filtered_params[key].present? && filtered_params[key].include?(option["value"])
      { label: option["label"], text: option["label"], value: option["value"], checked: checked }
    end
  end

  ###
  # Question types
  ###

  def single_wrapped?
    type == "single_wrapped"
  end

  def multiple?
    type == "multiple"
  end

  def self.load_all
    file = YAML.load_file("lib/checklists/questions.yaml")
    file["questions"].map do |question|
      Checklists::Question.new(question)
    end
  end
end
