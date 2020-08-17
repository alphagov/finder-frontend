class BrexitChecker::Criteria::Evaluator
  def initialize(expression, selected_criteria)
    @expression = expression
    @selected_criteria = selected_criteria
  end

  def evaluate
    return true if expression.blank?

    evaluate_node(expression)
  end

  def self.evaluate(*args)
    new(*args).evaluate
  end

  private_class_method :new

private

  attr_reader :expression, :selected_criteria

  def evaluate_node(node)
    case node
    when Array
      evaluate_all_of(node)
    when Hash
      evaluate_hash(node)
    when String
      selected_criteria.include?(node)
    end
  end

  def evaluate_hash(node)
    if node["any_of"]
      evaluate_any_of(node["any_of"])
    elsif node["all_of"]
      evaluate_all_of(node["all_of"])
    else
      raise "Unknown node: #{node}"
    end
  end

  def evaluate_all_of(nodes)
    nodes.all? { |node| evaluate_node(node) }
  end

  def evaluate_any_of(nodes)
    nodes.any? { |node| evaluate_node(node) }
  end
end
