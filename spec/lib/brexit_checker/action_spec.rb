require "spec_helper"

RSpec.describe BrexitChecker::Action do
  describe "validations" do
    let(:action_missing_attributes) do
      FactoryBot.build(:brexit_checker_action,
                       id: nil,
                       title: nil,
                       consequence: nil)
    end

    let(:action_with_invalid_audience) { FactoryBot.build(:brexit_checker_action, audience: "clowns") }
    let(:action_missing_link_text) { FactoryBot.build(:brexit_checker_action, guidance_url: "/brexity_fun") }
    let(:action_with_invalid_priority) { FactoryBot.build(:brexit_checker_action, priority: "high") }
    let(:action_with_missing_criteria) { FactoryBot.build(:brexit_checker_action, criteria: []) }
    let(:action_with_missing_grouping_criteria) { FactoryBot.build(:brexit_checker_action, grouping_criteria: nil) }

    it "id, title, consequence and criteria can't be blank" do
      message = "Validation failed: Id can't be blank, Title can't be blank, Consequence can't be blank"
      expect { action_missing_attributes.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "audience can only be business or citizen" do
      message = "Validation failed: Audience is not included in the list"
      expect { action_with_invalid_audience.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "guidance links must have text and url" do
      message = "Validation failed: Guidance link text can't be blank"
      expect { action_missing_link_text.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "priority must be an integer" do
      message = "Validation failed: Priority is not a number"
      expect { action_with_invalid_priority.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "must have criteria" do
      message = "Validation failed: Criteria can't be blank"
      expect { action_with_missing_criteria.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end

    it "must have grouping criteria" do
      message = "Validation failed: Grouping criteria can't be blank"
      expect { action_with_missing_grouping_criteria.valid? }.to raise_error(ActiveModel::ValidationError, message)
    end
  end

  describe "factories" do
    it "has a valid default business action factory" do
      action = FactoryBot.build(:brexit_checker_action)
      expect(action.valid?).to be(true)
    end

    it "has a valid citizen trait factory" do
      action = FactoryBot.build(:brexit_checker_action, :citizen)
      expect(action.valid?).to be(true)
    end
  end

  describe "#all_criteria" do
    let(:criteria_a) { FactoryBot.build(:brexit_checker_criterion, key: "owns-operates-business-organisation", text: "You own or run a business or organisation") }
    let(:criteria_b) { FactoryBot.build(:brexit_checker_criterion, key: "forestry", text: "You work in plants and forestry") }
    let(:criteria_c) { FactoryBot.build(:brexit_checker_criterion, key: "vet", text: "You work in veterinary services") }
    let(:criteria_d) { FactoryBot.build(:brexit_checker_criterion, key: "charity", text: "You work in the charity sector") }
    let(:criteria_e) { FactoryBot.build(:brexit_checker_criterion, key: "living-uk", text: "You live in the UK") }
    let(:criteria_f) { FactoryBot.build(:brexit_checker_criterion, key: "working-eu", text: "You are employed in the EU") }

    it "returns an array of criterion keys when criterion keys are also stored as an array of keys" do
      action = FactoryBot.build(:brexit_checker_action, criteria: %w[owns-operates-business-organisation forestry vet])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an OR criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: [{ "any_of" => %w[owns-operates-business-organisation forestry vet] }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an AND criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: [{ "all_of" => %w[owns-operates-business-organisation forestry vet] }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c].map(&:text))
    end

    it "returns an array of criterion keys from an array and OR criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: ["owns-operates-business-organisation", { "any_of" => %w[forestry vet charity] }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c, criteria_d].map(&:text))
    end

    it "returns an array of criterion keys from an array an AND criteria data structure" do
      action = FactoryBot.build(:brexit_checker_action, criteria: ["owns-operates-business-organisation", { "all_of" => %w[forestry vet charity] }])
      expect(action.all_criteria.map(&:text)).to match_array([criteria_a, criteria_b, criteria_c, criteria_d].map(&:text))
    end

    it "returns an array of criteiron keys from an AND and OR criteria data structure" do
      action = FactoryBot.build(
        :brexit_checker_action,
        criteria: [
          { "any_of" => %w[owns-operates-business-organisation forestry vet] },
          { "all_of" => %w[charity living-uk working-eu] },
        ],
      )
      expect(action.all_criteria.map(&:text)).to match_array(
        [criteria_a, criteria_b, criteria_c, criteria_d, criteria_e, criteria_f].map(&:text),
      )
    end
  end

  describe "#show?" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S01", criteria: %w[living-uk], grouping_criteria: %w[living-uk]) }
    let(:criteria_key_a) { "living-uk" }
    let(:criteria_key_b) { "working-eu" }

    it "returns true if the criteria key array includes a criterion found on the action" do
      expect(action1.show?([criteria_key_a])).to be(true)
    end

    it "returns false if the criteria key array does not include a criterion found on the action" do
      expect(action1.show?([criteria_key_b])).to be(false)
    end
  end

  describe "#find_by_id" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S01", criteria: %w[living-uk], grouping_criteria: %w[living-uk]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S02", criteria: %w[join-family-uk-yes], grouping_criteria: %w[living-uk]) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S03", criteria: %w[nationality-uk], grouping_criteria: %w[living-uk]) }
    let(:action4) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S04", criteria: %w[visiting-driving], grouping_criteria: %w[visiting-eu]) }
    let(:action5) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S05", criteria: %w[studying-eu], grouping_criteria: %w[studying-eu]) }

    before :each do
      allow(BrexitChecker::Action).to receive(:load_all).and_return([action1, action2, action3, action4, action5])
    end

    it "loads all actions and selecteds a relevant one by ID" do
      expect(BrexitChecker::Action.find_by_id("S01")).to eql(action1)
    end
  end

  describe "#all_criteria_keys" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S01", criteria: %w[living-uk], grouping_criteria: %w[living-uk]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S02", criteria: %w[join-family-uk-yes living-uk], grouping_criteria: %w[living-uk]) }
    let(:criteria1) { FactoryBot.build(:brexit_checker_criterion, key: "living-uk", text: "Living in the UK") }
    let(:criteria2) { FactoryBot.build(:brexit_checker_criterion, key: "join-family-uk-yes", text: "You plan to join an EU or EEA family member in the UK") }

    before :each do
      allow(BrexitChecker::Criterion).to receive(:load_all).and_return([criteria1, criteria2])
    end

    it "returns a single criteria key from the action" do
      expect(action1.all_criteria_keys).to eq(%w[living-uk])
    end

    it "returns multiple criteria keys from the action" do
      expect(action2.all_criteria_keys).to eq(%w[join-family-uk-yes living-uk])
    end
  end

  describe "#hash & #eql?" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S01") }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S01") }
    let(:action3) { FactoryBot.build(:brexit_checker_action, :citizen, id: "S02") }

    it "correctly removes duplicates from an array by id" do
      expect([action1, action2, action3].uniq.map(&:id)).to eq(%w[S01 S02])
    end
  end

  describe "#multiple_grouping_criteria?" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, :citizen, grouping_criteria: %w[living-uk]) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, :citizen, grouping_criteria: %w[living-uk visiting-eu]) }

    it "returns true if action has more than one grouping criteria" do
      expect(action1.multiple_grouping_criteria?).to be false
      expect(action2.multiple_grouping_criteria?).to be true
    end
  end
end
