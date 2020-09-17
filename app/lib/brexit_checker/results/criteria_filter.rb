class BrexitChecker::Results::CriteriaFilter
  attr_reader :action, :group_key, :selected_criteria

  def initialize(action, group_key, selected_criteria)
    @action = action
    @group_key = group_key
    @selected_criteria = selected_criteria
  end

  def self.call(*args)
    new(*args).filter
  end

  def filter
    action.multiple_grouping_criteria? ? filtered_criteria : criteria
  end

private

  def filtered_criteria
    criteria.reject do |criterion|
      irrelevant_criteria_keys.include? criterion.key
    end
  end

  def irrelevant_criteria_keys
    action.grouping_criteria - [group_key]
  end

  def criteria
    action.all_criteria & selected_criteria
  end
end
