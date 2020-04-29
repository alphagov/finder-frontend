require "spec_helper"

RSpec.describe BrexitChecker::Group do
  describe "factories" do
    it "has a valid default factory" do
      group = FactoryBot.build(:brexit_checker_group)
      expect(group.valid?).to be(true)
    end
  end

  describe "#hash & #eql?" do
    let(:group1) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu") }
    let(:group2) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu") }
    let(:group3) { FactoryBot.build(:brexit_checker_group, key: "living-uk") }

    it "correctly removes duplicates from an array by key" do
      expect([group1, group2, group3].uniq.map(&:key)).to eq(%w[visiting-eu living-uk])
    end
  end

  describe "#actions" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, id: "S01", grouping_criteria: %w[visiting-eu]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, id: "S02", grouping_criteria: %w[living-ie]) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, id: "S03", grouping_criteria: %w[living-ie]) }
    let(:group1) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu") }
    let(:group2) { FactoryBot.build(:brexit_checker_group, key: "living-ie") }
    let(:group3) { FactoryBot.build(:brexit_checker_group, key: "studying-uk") }

    before :each do
      allow(BrexitChecker::Action).to receive(:load_all).and_return([action1, action2, action3])
    end

    it "retuns an action when a grouping_criteira matches the group key" do
      expect(group1.actions).to match_array([action1])
    end

    it "retuns multiple actions when multiple grouping_criteira match the group key" do
      expect(group2.actions).to match_array([action2, action3])
    end

    it "retuns an empty array when no action's grouping_criteira match the group key" do
      expect(group3.actions).to match_array([])
    end
  end
end
