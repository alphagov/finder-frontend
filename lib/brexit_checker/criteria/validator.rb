require "set"

class BrexitChecker::Criteria::Validator
  def initialize(expression)
    @expression = expression
  end

  def validate
    return true if expression.nil?

    criteria = BrexitChecker::Criteria::Extractor.expression_criteria(expression)
    criteria.subset?(all_criteria)
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
end
