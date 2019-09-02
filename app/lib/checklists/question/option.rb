class Checklists::Question::Option
  attr_reader :label, :value, :sub_options, :hint_text, :criteria

  def self.load_all(options)
    options.map { |o| new(o) }
  end

  def initialize(params)
    @label = params['label']
    @value = params['value']
    @sub_options = Checklists::Question::Option.load_all(params['options'].to_a)
    @hint_text = params['hint_text']
    @criteria = params['criteria']
  end

  def show?(criteria_keys)
    Checklists::CriteriaLogic.new(criteria, criteria_keys).applies?
  end
end
