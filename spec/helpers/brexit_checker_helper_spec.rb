require "spec_helper"

describe BrexitCheckerHelper, type: :helper do
  describe "#filter_items" do
    it "filters actions that should be shown" do
      action1 = instance_double BrexitChecker::Action, show?: true
      action2 = instance_double BrexitChecker::Action, show?: false
      expect(action1).to receive(:show?).with([])
      expect(action2).to receive(:show?).with([])
      results = filter_items([action1, action2], [])
      expect(results).to eq([action1])
    end

    it "filters options that should be shown" do
      option1 = instance_double BrexitChecker::Question::Option, show?: true
      option2 = instance_double BrexitChecker::Question::Option, show?: false
      expect(option1).to receive(:show?).with([])
      expect(option2).to receive(:show?).with([])
      results = filter_items([option1, option2], [])
      expect(results).to eq([option1])
    end
  end

  describe "#format_action_audiences" do
    let(:action1) { FactoryBot.build(:brexit_checker_action, audience: "citizen", priority: 5) }
    let(:action2) { FactoryBot.build(:brexit_checker_action, audience: "citizen", priority: 8) }
    let(:action3) { FactoryBot.build(:brexit_checker_action, audience: "business", priority: 5) }
    let(:action4) { FactoryBot.build(:brexit_checker_action, audience: "business", priority: 5) }

    subject { format_action_audiences(actions) }

    context "when there are actions for each audience" do
      let(:actions) { [action1, action2, action3, action4] }

      it "return actions grouped by audience and sorted by priority" do
        expect(subject).to eq([
          {
            heading: I18n.t("brexit_checker.results.audiences.citizen.heading"),
            actions: [action2, action1],
          },
          {
            heading: I18n.t("brexit_checker.results.audiences.business.heading"),
            actions: [action3, action4],
          },
        ])
      end
    end
  end

  describe "#persistent_criteria_keys" do
    let(:criteria_keys) { %w[A B C D] }
    let(:question_criteria_keys) { %w[C D] }

    subject { persistent_criteria_keys(question_criteria_keys) }

    it "returns all but the questions criteria" do
      expect(subject).to contain_exactly("A", "B")
    end
  end

  describe "#next_question_index" do
    let(:q1) { FactoryBot.build(:brexit_checker_question) }
    let(:q2) { FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(a b) }]) }
    let(:q3) { FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(c d) }]) }
    let(:q4) { FactoryBot.build(:brexit_checker_question, criteria: %w(c)) }

    let(:questions) { [q1, q2, q3, q4] }

    subject {
      next_question_index(
        all_questions: questions,
        criteria_keys: criteria_keys,
        previous_question_index: previous_question_index,
      )
    }

    before do
      allow(q1).to receive(:show?) { true }
      allow(q2).to receive(:show?) { false }
      allow(q2).to receive(:show?).with(%w(a b)) { true }
      allow(q3).to receive(:show?) { false }
      allow(q3).to receive(:show?).with(%w(c d)) { true }
      allow(q4).to receive(:show?) { false }
      allow(q4).to receive(:show?).with(%w(c)) { true }
    end

    context "previous question id is zero" do
      let(:previous_question_index) { 0 }
      let(:criteria_keys) { [] }
      it "returns first question" do
        expect(subject).to eq(0)
      end
    end

    context "previous question id is one and the criteria matches question two" do
      let(:previous_question_index) { 1 }
      let(:criteria_keys) { %w[a b] }
      it "returns question two" do
        expect(subject).to eq(1)
      end
    end

    context "previous question id is one and the criteria matches question three" do
      let(:previous_question_index) { 1 }
      let(:criteria_keys) { %w[c d] }
      it "returns question three" do
        expect(subject).to eq(2)
      end
    end

    context "previous question id is one and the criteria does any futher questions" do
      let(:previous_question_index) { 1 }
      let(:criteria_keys) { %w[e] }
      it "does not return a question" do
        expect(subject).to be nil
      end
    end

    context "previous question id is higher than the number of questions" do
      let(:previous_question_index) { questions.count + 1 }
      let(:criteria_keys) { [] }
      it "does not return a question" do
        expect(subject).to be nil
      end
    end
  end
end
