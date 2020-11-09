require "spec_helper"

RSpec.describe "Brexit checker data integrity" do
  let(:extractor) { BrexitChecker::Criteria::Extractor }
  let(:all_criteria_keys) { BrexitChecker::Criterion.load_all.map(&:key).to_set }
  let(:all_action_ids) { BrexitChecker::Action.load_all.map(&:id) }

  BrexitChecker::Question.load_all.each do |question|
    it "ensures question '#{question.key}' references valid criteria" do
      expect(all_criteria_keys).to include(*extractor.extract(question.criteria))
    end

    it "ensures question '#{question.key}' options reference valid criteria" do
      expect(all_criteria_keys).to include(*extractor.extract(question.all_values))
    end
  end

  BrexitChecker::Action.load_all.each do |action|
    it "ensures action '#{action.id}' references valid criteria" do
      expect(all_criteria_keys).to include(*extractor.extract(action.criteria))
    end
  end

  BrexitChecker::Notification.load_all.each do |notification|
    it "ensures notification '#{notification.id}' references a valid action" do
      expect(all_action_ids).to include(notification.action_id)
    end
  end

  it "has questions with unique keys" do
    ids = BrexitChecker::Question.load_all(&:key)
    expect(ids.uniq).to match_array ids
  end

  it "has actions with unique IDs" do
    expect(all_action_ids.uniq).to match_array all_action_ids
  end

  it "has criteria with unique keys" do
    expect(all_criteria_keys.uniq).to match_array all_criteria_keys
  end

  it "has notifications with unique IDs" do
    keys = BrexitChecker::Notification.load_all.map(&:id)
    expect(keys.uniq).to match_array keys
  end

  it "has criteria that are covered by a question" do
    possible_criteria = BrexitChecker::Question.load_all
      .flat_map(&:all_values)

    expect(all_criteria_keys).to include(*possible_criteria)
  end

  it "has criteria that occur only once in the questions" do
    possible_criteria = BrexitChecker::Question.load_all
      .flat_map(&:all_values)

    expect(possible_criteria.uniq).to match_array possible_criteria
  end

  it "groups.yaml contains valid groups" do
    expect { BrexitChecker::Group.load_all }.not_to raise_error
  end
end
