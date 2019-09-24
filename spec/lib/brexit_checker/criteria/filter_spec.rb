require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Filter do
  describe "#call" do
    let(:question1) do
      FactoryBot.build :brexit_checker_question, options: [
        FactoryBot.build(:brexit_checker_option, value: "c1", sub_options: [
          FactoryBot.build(:brexit_checker_option, value: "c2"),
        ]),
      ]
    end

    let(:question2) do
      FactoryBot.build :brexit_checker_question, options: [
        FactoryBot.build(:brexit_checker_option, value: "c3"),
      ]
    end

    let(:question3) do
      FactoryBot.build :brexit_checker_question, options: [
        FactoryBot.build(:brexit_checker_option, label: "Option group", sub_options: [
          FactoryBot.build(:brexit_checker_option, value: "c4"),
        ]),
      ]
    end

    before do
      allow(question1).to receive(:show?) { true }
      allow(question2).to receive(:show?) { false }
      allow(question2).to receive(:show?).with(array_including("c2")) { true }
      allow(question3).to receive(:show?) { false }
      allow(question3).to receive(:show?).with(array_including("c3")) { true }

      allow(BrexitChecker::Question).to receive(:load_all) do
        [question1, question2, question3]
      end
    end

    it "preserves criteria for questions without dependencies" do
      criteria = subject.call(%w(c1))
      expect(criteria).to include("c1")
    end

    it "filters criteria that are not present in any question" do
      criteria = subject.call(%w(c5))
      expect(criteria).to be_empty
    end

    it "filters criteria for questions with unmet dependencies" do
      criteria = subject.call(%w(c3))
      expect(criteria).to be_empty
    end

    it "preserves criteria for questions with met dependencies" do
      criteria = subject.call(%w(c1 c2 c3))
      expect(criteria).to include("c3").and match_array(criteria)
    end

    it "transitively filters criteria for follow-on questions" do
      criteria = subject.call(%w(c2 c3 c4))
      expect(criteria).to be_empty
    end

    it "preserves criteria coming from applicable sub-options" do
      criteria = subject.call(%w(c1 c2))
      expect(criteria).to include("c2").and match_array(criteria)
    end

    it "filters criteria coming from deselected sub-options" do
      criteria = subject.call(%w(c2))
      expect(criteria).to be_empty
    end
  end
end
