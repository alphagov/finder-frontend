class BrexitChecker::Question::Option
  include ActiveModel::Validations

  validates_presence_of :label

  attr_reader :label, :value, :sub_options, :hint_text, :exclude_if

  def initialize(attrs)
    attrs.each { |key, value| instance_variable_set("@#{key}", value) }
    validate!
  end

  def self.load(params)
    parsed_params = params.dup
    parsed_params["sub_options"] = load_all(params["options"].to_a)
    new(parsed_params)
  end

  def self.load_all(options)
    options.map { |o| load(o) }
  end
end
