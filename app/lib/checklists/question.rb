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

  def self.find_by_key(key)
    load_all.find { |q| q.key == key }
  end

  def show?(criteria)
    depends_on.blank? || (depends_on - criteria).empty?
  end

  def possible_criteria
    sub_options = options.flat_map { |o| o['options'].to_a }
    (options + sub_options).map { |o| o['value'] }
  end

  def multiple?
    type == "multiple"
  end

  def single_wrapped?
    type == "single_wrapped"
  end

  def self.load_all
    CHECKLISTS_QUESTIONS.map do |question|
      Checklists::Question.new(question)
    end
  end
end
