class Checklists::Action
  attr_accessor :title, :description, :path, :due_date, :applicable_criteria

  def initialize(params)
    @title = params['title']
    @description = params['description']
    @path = params['path']
    @due_date = params['due_date']
    @applicable_criteria = params['applicable_criteria']
  end

  def applies_to?(criteria_keys)
    applicable_criteria.any? do |key|
      criteria_keys.include?(key)
    end
  end

  def self.load_all
    CHECKLISTS_ACTIONS.map { |a| new(a) }
  end
end
