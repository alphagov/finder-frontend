class Checklists::Question
  attr_reader :key, :text, :description, :hint_title, :hint_text,
              :options, :type, :depends_on

  def initialize(params)
    @key            = params['key']
    @text           = params['question']
    @description    = params['description']
    @hint_title     = params['hint_title']
    @hint_text      = params['hint_text']
    @options        = params['options']
    @type           = params['question_type']
    @depends_on     = params['depends_on']
  end

  def show?(criteria)
    depends_on.blank? || (depends_on - criteria).empty?
  end

  def formatted_options(filtered_params)
    options.map do |option|
      checked = filtered_params[key].present? && filtered_params[key].include?(option["value"])
      { label: option["label"], text: option["label"], value: option["value"], checked: checked }
    end
  end

  def multiple?
    type == "multiple"
  end

  def self.load_all
    CHECKLISTS_QUESTIONS.map do |question|
      Checklists::Question.new(question)
    end
  end
end
