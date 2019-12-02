require "spec_helper"

RSpec.describe "Brexit checker data integrity" do
  let(:extractor) { BrexitChecker::Criteria::Extractor }
  let(:all_criteria) { BrexitChecker::Criterion.load_all.map(&:key).to_set }

  it "has questions that reference valid criteria" do
    BrexitChecker::Question.load_all.each do |question|
      expect(all_criteria).to include(*extractor.extract(question.criteria))
    end
  end

  it "has actions that reference valid criteria" do
    BrexitChecker::Action.load_all.each do |action|
      expect(all_criteria).to include(*extractor.extract(action.criteria))
    end
  end

  it "has notifications that reference valid actions" do
    ids = BrexitChecker::Action.load_all.map(&:id)

    BrexitChecker::Notification.load_all.each do |notification|
      expect(ids).to include(notification.action_id)
    end
  end

  it "has question options that reference valid criteria" do
    BrexitChecker::Question.load_all.flat_map(&:all_values).each do |value|
      expect(all_criteria).to include(*extractor.extract([value]))
    end
  end

  it "has questions with unique keys" do
    ids = BrexitChecker::Question.load_all(&:key)
    expect(ids.uniq.count).to eq ids.count
  end

  it "has actions with unique IDs" do
    ids = BrexitChecker::Action.load_all(&:id)
    expect(ids.uniq.count).to eq ids.count
  end

  it "has criteria with unique keys" do
    keys = BrexitChecker::Criterion.load_all.map(&:key)
    expect(keys.uniq.count).to eq(keys.count)
  end

  it "has notifications with unique IDs" do
    keys = BrexitChecker::Notification.load_all.map(&:id)
    expect(keys.uniq.count).to eq(keys.count)
  end

  it "has criteria that are covered by a question" do
    possible_criteria = BrexitChecker::Question.load_all
      .flat_map(&:all_values)

    BrexitChecker::Criterion.load_all.each do |criterion|
      expect(possible_criteria).to include(criterion.key)
    end
  end

  it "has criteria that occur only once in the questions" do
    possible_criteria = BrexitChecker::Question.load_all
      .flat_map(&:all_values)

    expect(possible_criteria.uniq.count).to eq possible_criteria.count
  end
end
