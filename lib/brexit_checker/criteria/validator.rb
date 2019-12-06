require "set"

class BrexitChecker::Criteria::Validator
  def initialize(expression)
    @expression = expression
  end

  def validate
    return true if expression.nil?

    expression_criteria.subset?(all_criteria)
  end

  def self.validate(*args)
    new(*args).validate
  end

  private_class_method :new

private

  attr_reader :expression

  def all_criteria
    BrexitChecker::Criterion.load_all.map(&:key).to_set
  end

  def expression_criteria
    extract_criteria(expression).to_set
  end

  def extract_criteria(object)
    case object
    when Array
      object.flat_map { |element| extract_criteria(element) }
    when Hash
      extract_criteria(object.fetch("any_of", [])) +
        extract_criteria(object.fetch("all_of", []))
    when String
      object
    end
  end
end
