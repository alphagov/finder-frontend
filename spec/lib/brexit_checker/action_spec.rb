require "spec_helper"

RSpec.describe BrexitChecker::Action do
  describe "#all_criteria" do
    let(:criteria_a) { FactoryBot.build(:brexit_checker_criterion, key: "owns-operates-business-organisation", text: "You own or operate a business or organisation") }
    let(:criteria_b) { FactoryBot.build(:brexit_checker_criterion, key: "forestry", text: "You work in plants and forestry") }
    let(:criteria_c) { FactoryBot.build(:brexit_checker_criterion, key: "vet", text: "You work in veterinary services") }
    let(:criteria_d) { FactoryBot.build(:brexit_checker_criterion, key: "charity", text: "You work in the charity sector") }
    let(:criteria_e) { FactoryBot.build(:brexit_checker_criterion, key: "living-uk", text: "You live in the UK") }
    let(:criteria_f) { FactoryBot.build(:brexit_checker_criterion, key: "working-eu", text: "You are employed in the EU") }

    it "returns an array of criterion keys when criterion keys are also stored as an array of keys" do
      action = FactoryBot.build(:brexit_checker_action, criteria: %w(owns-operates-business-organisation forestry vet))
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an OR criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: [{ "any_of" => %w(owns-operates-business-organisation forestry vet) }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an AND criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: [{ "all_of" => %w(owns-operates-business-organisation forestry vet) }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an array and OR criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: ["owns-operates-business-organisation", { "any_of" => %w(forestry vet charity) }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c, criteria_d].map(&:text))
    end

    it "returns an array of criterion keys from an array an AND criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: ["owns-operates-business-organisation", { "all_of" => %w(forestry vet charity) }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c, criteria_d].map(&:text))
    end

    it "returns an array of criteiron keys from an AND and OR criteria data structure" do
      action = FactoryBot.build(
        :brexit_checker_action,
        criteria: [
          { "any_of" => %w(owns-operates-business-organisation forestry vet) },
          { "all_of" => %w(charity living-uk working-eu) },
        ],
      )
      expect(action.all_criteria.map(&:text)).to match_array(
        [criteria_a, criteria_b, criteria_c, criteria_d, criteria_e, criteria_f].map(&:text),
      )
    end
  end
end
