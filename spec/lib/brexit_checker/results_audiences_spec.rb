require "spec_helper"

describe BrexitChecker::ResultsAudiences do
  describe "#populate_citizen_groups" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[living-uk living-row], grouping_criteria: %w[living-uk]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[join-family-uk-yes], grouping_criteria: %w[living-uk]) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[nationality-uk], grouping_criteria: %w[living-uk]) }
    let(:action4) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[visiting-driving], grouping_criteria: %w[visiting-eu]) }
    let(:action5) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[studying-eu], grouping_criteria: %w[studying-eu]) }
    let(:action6) { FactoryBot.build(:brexit_checker_action, :citizen, criteria: %w[living-uk visiting-ie], grouping_criteria: %w[living-uk visiting-ie]) }

    let(:criteria1) { FactoryBot.build(:brexit_checker_criterion, key: "living-uk", text: "Living in the UK") }
    let(:criteria2) { FactoryBot.build(:brexit_checker_criterion, key: "join-family-uk-yes", text: "You plan to join an EU or EEA family member in the UK") }
    let(:criteria3) { FactoryBot.build(:brexit_checker_criterion, key: "nationality-uk", text: "You are a British national") }
    let(:criteria4) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-driving", text: "You need to drive abroad") }
    let(:criteria5) { FactoryBot.build(:brexit_checker_criterion, key: "studying-eu", text: "You are studying in the EU") }
    let(:criteria6) { FactoryBot.build(:brexit_checker_criterion, key: "living-row", text: "You do not live in the UK or the EU") }
    let(:criteria7) { FactoryBot.build(:brexit_checker_criterion, key: "visiting-ie", text: "Visiting Ireland") }

    let(:group_living_uk) { FactoryBot.build(:brexit_checker_group, key: "living-uk", heading: "Living in the UK") }
    let(:group_visiting_eu) { FactoryBot.build(:brexit_checker_group, key: "visiting-eu", heading: "Visiting the EU") }
    let(:group_studying_eu) { FactoryBot.build(:brexit_checker_group, key: "studying-eu", heading: "Studying in the EU") }
    let(:group_visiting_ie) { FactoryBot.build(:brexit_checker_group, key: "visiting-ie", heading: "Visiting Ireland") }

    let(:selected_criteria) { [criteria1, criteria2, criteria3, criteria4, criteria5] }
    let(:actions) { [action1, action2, action3, action4, action5, action6] }

    before :each do
      allow(BrexitChecker::Action).to receive(:load_all).and_return([action1, action2, action3, action4, action5, action6])
      allow(BrexitChecker::Criterion).to receive(:load_all).and_return([criteria1, criteria2, criteria3, criteria4, criteria5, criteria6, criteria7])
      allow(BrexitChecker::Group).to receive(:load_all).and_return([group_living_uk, group_visiting_eu, group_studying_eu, group_visiting_ie])
    end

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
            group: group_living_uk,
            actions: [action1, action2, action3, action6],
            criteria: [criteria1, criteria2, criteria3],
          },
          {
            group: group_visiting_eu,
            actions: [action4],
            criteria: [criteria4],
          },
          {
            group: group_studying_eu,
            actions: [action5],
            criteria: [criteria5],
          },
          {
            group: group_visiting_ie,
            actions: [action6],
            criteria: [criteria1],
          },
        ]

        expect(result).to eql(grouped_actions_fixture)
      end
    end
  end

  describe "#populate_business_groups" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, criteria: %w[owns-operates-business-organisation automotive]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, criteria: %w[aero-space]) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, criteria: %w[forestry]) }
    let(:criteria1) { FactoryBot.build(:brexit_checker_criterion, key: "owns-operates-business-organisation", text: "You own or operate a business or organisation") }
    let(:criteria2) { FactoryBot.build(:brexit_checker_criterion, key: "aero-space", text: "You work in the aerospace and space industry") }
    let(:criteria3) { FactoryBot.build(:brexit_checker_criterion, key: "forestry", text: "You work in plants and forestry") }
    let(:criteria4) { FactoryBot.build(:brexit_checker_criterion, key: "exports-enchanted-goods", text: "You export enchanted amulets") }
    let(:criteria5) { FactoryBot.build(:brexit_checker_criterion, key: "automotive", text: "You work in the automotive industry") }

    let(:selected_criteria) { [criteria1, criteria2, criteria3, criteria4] }
    let(:actions) { [action1, action2, action3] }

    before :each do
      allow(BrexitChecker::Action).to receive(:load_all).and_return([action1, action2, action3])
      allow(BrexitChecker::Criterion).to receive(:load_all).and_return([criteria1, criteria2, criteria3, criteria4, criteria5])
    end

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

      it "produces an hash of actions and criteria" do
        expect(result[:actions]).to eq(actions)
        expect(result[:criteria]).to match_array([criteria1, criteria2, criteria3])
      end
    end
  end
end
