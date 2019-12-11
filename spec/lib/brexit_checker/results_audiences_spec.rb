require "spec_helper"

describe BrexitChecker::ResultsAudiences do
  describe "#populate_citizen_groups" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w(living-uk), grouping_criteria: %w(living-uk)) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w(join-family-uk-yes), grouping_criteria: %w(living-uk)) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w(nationality-uk), grouping_criteria: %w(living-uk)) }
    let(:action4) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w(visiting-driving), grouping_criteria: %w(visiting-eu)) }
    let(:action5) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w(studying-eu), grouping_criteria: %w(studying-eu)) }

    let(:criteria1) { FactoryBot.build(:brexit_checker_criterion, key: "living-uk", text: "Living in the UK") }
    let(:criteria2) { FactoryBot.build(:brexit_checker_criterion, key: "join-family-uk-yes", text: "You plan to join an EU or EEA family member in the UK") }
    let(:criteria3) { FactoryBot.build(:brexit_checker_criterion, key: "nationality-uk", text: "You are a British national") }
    let(:criteria4) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-driving", text: "You need to drive abroad") }
    let(:criteria5) { FactoryBot.build(:brexit_checker_criterion, key: "studying-eu", text: "You are studying in the EU") }

    let(:group_living_uk) { FactoryBot.build(:brexit_checker_group, key: "living-uk", heading: "Living in the UK") }
    let(:group_visiting_eu) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu", heading: "Visiting the EU") }
    let(:group_studying_eu) { FactoryBot.build(:brexit_checker_group, key: "studying-eu", heading: "Studying in the EU") }

    let(:selected_criteria) { [criteria1, criteria2, criteria3, criteria4, criteria5] }
    let(:actions) { [action1, action2, action3, action4] }

    context "actions are provided but there are no criteria" do
      let(:result) { described_class.populate_citizen_groups(actions, []) }
      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "criteria are provided but there are no actions" do
      let(:result) { described_class.populate_citizen_groups([], selected_criteria) }
      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "actions and criteria are provided" do
      let(:result) { described_class.populate_citizen_groups(actions, selected_criteria) }

      it "produces an array of group hashes" do
        grouped_actions_fixture = [
          {
            group: group_visiting_eu,
            actions: [action4],
            criteria: [criteria4],
          },
          {
            group: group_living_uk,
            actions: [action1, action2, action3],
            criteria: [criteria1, criteria3, criteria2],
          },
          {
            group: group_studying_eu,
            actions: [action5],
            criteria: [criteria5],
          },
        ]
        expect(result[0][:group].heading).to eql(grouped_actions_fixture[0][:group].heading)
        expect(result[0][:group].key).to eql(grouped_actions_fixture[0][:group].key)
      end
    end
  end

  describe "#populate_business_groups" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, criteria: %w(owns-operates-business-organisation)) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, criteria: %w(aero-space)) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, criteria: %w(forestry)) }
    let(:criteria1) { FactoryBot.build(:brexit_checker_criterion, key: "owns-operates-business-organisation", text: "You own or operate a business or organisation") }
    let(:criteria2) { FactoryBot.build(:brexit_checker_criterion, key: "aero-space", text: "You work in the aerospace and space industry") }
    let(:criteria3) { FactoryBot.build(:brexit_checker_criterion, key: "forestry", text: "You work in plants and forestry") }
    let(:criteria4) { FactoryBot.build(:brexit_checker_criterion, key: "exports-enchanted-goods", text: "You export enchanted amulets") }
    let(:selected_criteria) { [criteria1, criteria2, criteria3, criteria4] }
    let(:actions) { [action1, action2, action3] }

    context "actions are provided but there are no criteria" do
      let(:result) { described_class.populate_business_groups(actions, []) }
      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "criteria are provided but there are no actions" do
      let(:result) { described_class.populate_business_groups([], selected_criteria) }
      it "returns an empty array" do
        expect(result).to be_empty
      end
    end

    context "actions and criteria are provided" do
      let(:result) { described_class.populate_business_groups(actions, selected_criteria) }
      let(:result_criteria_keys) { result[:criteria].map(&:key) }

      it "produces an hash of actions and criteria" do
        expect(result[:actions]).to eq(actions)
        expect(result_criteria_keys).to match_array([criteria1.key, criteria2.key, criteria3.key])
      end

      it "excludes answer criteria that are not relevant to actions" do
        expect(result_criteria_keys).not_to include("exports-enchanted-goods")
        expect(result_criteria_keys).to include("owns-operates-business-organisation")
        expect(result_criteria_keys).to include("aero-space")
        expect(result_criteria_keys).to include("forestry")
      end

      it "has a criteria key that matches criteria on the actions" do
        basic_action_criteira = result[:actions].flat_map(&:criteria)
        expect(result_criteria_keys).to eq(basic_action_criteira)
      end
    end
  end
end
