require "spec_helper"

describe BrexitChecker::Results::CriteriaFilter do
  let(:criteria_1) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-eu") }
  let(:criteria_2) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-uk") }
  let(:criteria_3) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-ie") }
  let(:criteria) { [{ "all_of" => [criteria_1.key, criteria_2.key] }] }
  let(:group_1) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu") }
  let(:group_2) { FactoryBot.build(:brexit_checker_group, key: "visiting-uk") }
  let(:action_1) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: criteria, grouping_criteria: [group_1.key]) }
  let(:action_2) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: criteria, grouping_criteria: [group_1.key, group_2.key]) }
  let(:selected_criteria) { [criteria_1, criteria_2, criteria_3] }

  before :each do
    allow(BrexitChecker::Criterion).to receive(:load_all).and_return([criteria_1, criteria_2, criteria_3])
  end

  describe "#call" do
    context "when the action has a single grouping criteria" do
      subject { described_class.call(action_1, group_1.key, selected_criteria) }
      it "returns all of the action's criteria" do
        expect(subject).to eq([criteria_1, criteria_2])
      end
    end

    context "when the action has multiple grouping criteria" do
      subject { described_class.call(action_2, group_1.key, selected_criteria) }
      it "returns only criteria that relate to group" do
        expect(subject).to eq([criteria_1])
      end
    end
  end
end
