class BrexitChecker::Question::Option
  include ActiveModel::Validations

  validates_presence_of :label

  attr_reader :label, :value, :sub_options, :hint_text, :criteria, :parent

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
  end

  def show?(criteria_keys)
    BrexitChecker::Criteria::Evaluator.evaluate(criteria, criteria_keys)
  end

  def self.load(params, parent)
    parsed_params = params.dup
    parsed_params["parent"] = parent
    parsed_params["sub_options"] = load_all(params["options"].to_a, self)
    new(parsed_params)
  end

  def self.load_all(options, parent = nil)
    options.map { |o| load(o, parent) }
  end
end
