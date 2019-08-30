class Checklists::Question
  CONFIG_PATH = Rails.root.join('lib', 'checklists', 'questions.yaml')

  attr_reader :key, :text, :description, :hint_title, :hint_text,
              :options, :type, :criteria

  def initialize(params)
    @key            = params['key']
    @text           = params['question']
    @description    = params['description']
    @hint_title     = params['hint_title']
    @hint_text      = params['hint_text']
    @options        = params['options']
    @type           = params['question_type']
    @criteria       = params['criteria']
  end

  def self.find_by_key(key)
    load_all.find { |q| q.key == key }
  end

  def valid?
    return false unless Checklists::CriteriaLogic.new(criteria, []).valid?

    possible_criteria.all? do |criterion|
      Checklists::CriteriaLogic.new(criterion, []).valid?
    end
  end

  def show?(selected_criteria)
    Checklists::CriteriaLogic.new(criteria, selected_criteria).applies?
  end

  def possible_criteria
    sub_options = options.flat_map { |o| o['options'].to_a }
    (options + sub_options).map { |o| o['value'] }
  end

  def multiple?
    type == "multiple"
  end

  def multiple_grouped?
    type == "multiple_grouped"
  end

  def single_wrapped?
    type == "single_wrapped"
  end

  def self.load_all
    @load_all = nil if Rails.env.development?

    @load_all ||= YAML.load_file(CONFIG_PATH)['questions']
      .map { |q| new(q) }
  end
end
