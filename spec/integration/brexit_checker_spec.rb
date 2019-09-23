require "spec_helper"

RSpec.describe "Brexit checker data integrity" do
  let(:validator) { BrexitChecker::Criteria::Validator }

  it "has questions that reference valid criteria" do
    BrexitChecker::Question.load_all.each do |question|
      expect(validator.validate(question.criteria)).to be_truthy
    end
  end

  it "has actions that reference valid criteria" do
    BrexitChecker::Action.load_all.each do |action|
      expect(validator.validate(action.criteria)).to be_truthy
    end
  end

  it "has change notes that reference valid actions" do
    ids = BrexitChecker::Action.load_all.map(&:id)

    BrexitChecker::ChangeNote.load_all.each do |change_note|
      expect(ids).to include(change_note.action_id)
    end
  end

  it "has question options that reference valid criteria" do
    BrexitChecker::Question.load_all.flat_map(&:all_values).each do |value|
      expect(validator.validate([value])).to be_truthy
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

  it "has change notes with unique IDs" do
    keys = BrexitChecker::ChangeNote.load_all.map(&:id)
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
