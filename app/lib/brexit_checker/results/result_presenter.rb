class BrexitChecker::Results::ResultPresenter
  attr_reader :criteria_keys

  def initialize(criteria_keys)
    @criteria_keys = criteria_keys
  end

  def criteria
    BrexitChecker::Criterion.load_by(criteria_keys)
  end

  def actions
    filtered = BrexitChecker::Action.load_all.select do |a|
      a.show?(criteria_keys)
    end
    sorted_actions(filtered)
  end

  def sorted_actions(actions)
    descending = -1
    actions.sort_by { |action| [(action.priority * descending), action.title] }
  end

  def business_results
    grouped_results.populate_business_groups
  end

  def citizen_results_groups
    grouped_results.populate_citizen_groups
  end

  def audience_actions
    actions.group_by(&:audience)
  end

  def grouped_results
    BrexitChecker::Results::GroupByAudience.new(audience_actions, criteria)
  end
end
