class BrexitChecker::Results::ResultPresenter
  attr_reader :criteria_keys

  def initialize(criteria_keys)
    @criteria_keys = criteria_keys
  end

  def criteria
    @criteria ||= BrexitChecker::Criterion.load_by(criteria_keys)
  end

  def actions
    filtered = all_actions.select { |a| a.show?(criteria_keys) }
    desc = -1
    filtered.sort_by { |action| [(action.priority * desc), action.title] }
  end

  def business_results
    grouped_results.populate_business_groups
  end

  def citizen_results_groups
    grouped_results.populate_citizen_groups
  end

private

  def all_actions
    @all_actions ||= BrexitChecker::Action.load_all
  end

  def audience_actions
    actions.group_by(&:audience)
  end

  def grouped_results
    BrexitChecker::Results::GroupByAudience.new(audience_actions, criteria)
  end
end
