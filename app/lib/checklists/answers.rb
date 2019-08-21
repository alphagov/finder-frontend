class Checklists::Answers
  attr_reader :criteria_keys

  def initialize(criteria_keys, actions)
    @criteria_keys = criteria_keys
    @actions = actions
  end

  def answers
    @answers ||= criteria.map { |c| { readable_text: c.text } }
  end



private

  attr_reader :actions

  def criteria
    @criteria ||= Checklists::Criterion.load_by(criteria_keys)
  end
end
