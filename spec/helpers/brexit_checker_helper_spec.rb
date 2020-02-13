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

  describe "#previous_question_index" do
    let(:q1) { FactoryBot.build(:brexit_checker_question) }
    let(:q2) { FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(a b) }]) }
    let(:q3) { FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(c d) }]) }
    let(:q4) { FactoryBot.build(:brexit_checker_question, criteria: %w(c)) }

    let(:questions) { [q1, q2, q3, q4] }

    subject {
      previous_question_index(
        all_questions: questions,
        criteria_keys: criteria_keys,
        current_question_index: current_question_index,
      )
    }

    context "current_question_index is 3 and the criteria matches question 3" do
      let(:current_question_index) { 3 }
      let(:criteria_keys) { %w[c d] }

      before do
        allow(q3).to receive(:show?) { true }
      end

      it "returns question 3" do
        expect(subject).to be(2)
      end
    end

    context "current_question_index is 3 and the criteria match question 2" do
      let(:current_question_index) { 3 }
      let(:criteria_keys) { %w[a b] }

      before do
        allow(q2).to receive(:show?) { true }
        allow(q3).to receive(:show?) { false }
      end

      it "returns question 2" do
        expect(subject).to be(1)
      end
    end

    context "current_question_index is 2 and the criteria do not match previous questions" do
      let(:current_question_index) { 2 }
      let(:criteria_keys) { %w[e] }

      before do
        allow(q1).to receive(:show?) { false }
        allow(q2).to receive(:show?) { false }
      end

      it "does not return a question" do
        expect(subject).to be nil
      end
    end

    context "current_question_index is 0 and there are no previous questions" do
      let(:current_question_index) { 0 }
      let(:criteria_keys) { %w[a] }

      it "does not return a question" do
        expect(subject).to be nil
      end
    end
  end

  describe "#notification_email_link" do
    let(:notification) { FactoryBot.build :brexit_checker_notification }

    it "returns the unchanged link when it's external" do
      link = notification_email_link("http://foo.bar", notification)
      expect(link).to eq("http://foo.bar")
    end

    it "adds tracking attributes for internal links" do
      link = notification_email_link("http://www.gov.uk", notification)
      expect(link).to match("utm_source=#{notification.id}")
      expect(link).to match("utm_medium=email")
      expect(link).to match("utm_campaign=govuk-brexit-checker")
      expect(link).to match("http://www.gov.uk?")
    end
  end

  describe "#brexit_results_email_link_label" do
    let(:actions) { [FactoryBot.build(:brexit_checker_action)] }

    it "returns the email link copy if there are actions" do
      expect(brexit_results_email_link_label(actions)).to eq(t("brexit_checker.results.email_sign_up_link"))
    end

    it "returns the no results email link copy if there are no actions" do
      expect(brexit_results_email_link_label([])).to eq(t("brexit_checker.results.email_sign_up_link_no_actions"))
    end
  end

  describe "#brexit_results_title" do
    let(:actions) { [FactoryBot.build(:brexit_checker_action)] }
    let(:criteria_keys) { %w"nationality-eu" }

    it "returns the title if there are actions and answers" do
      expect(brexit_results_title(actions, criteria_keys)).to eq(t("brexit_checker.results.title"))
    end

    it "returns the meta title if there are actions and no answers" do
      expect(brexit_results_title(actions, [])).to eq(t("brexit_checker.results.title"))
    end

    it "returns the no actions title if there are answers but no actions" do
      expect(brexit_results_title([], criteria_keys)).to eq(t("brexit_checker.results.title_no_actions"))
    end

    it "returns the no answers title if there no answers and no actions" do
      expect(brexit_results_title([], [])).to eq(t("brexit_checker.results.title_no_answers"))
    end
  end

  describe "#brexit_results_description" do
    let(:actions) { [FactoryBot.build(:brexit_checker_action, grouping_criteria: "visiting-eu")] }
    let(:criteria_keys) { %w"nationality-eu" }

    it "returns the desciption if there are actions and answers" do
      expect(brexit_results_description(actions, criteria_keys)).to eq(t("brexit_checker.results.description"))
    end

    it "returns the desciption if there are actions and no answers" do
      expect(brexit_results_description(actions, [])).to eq(t("brexit_checker.results.description"))
    end

    it "returns the no actions desciption if there are answers but no actions" do
      expect(brexit_results_description([], criteria_keys)).to eq(t("brexit_checker.results.description_no_actions"))
    end

    it "returns the no answers desciption there no answers and no actions" do
      expect(brexit_results_description([], [])).to eq(t("brexit_checker.results.description_no_answers").html_safe)
    end
  end

  describe "#criteria_aside_label" do
    it "returns string 'buisness-criteira' if not provided with a group heading" do
      expect(criteria_aside_label).to eql("business-actions-criteria")
    end

    it "returns an identifying string for citizen group criteria if provided with a group heading" do
      expect(criteria_aside_label("I am an Official Group heading")).to eq("you-and-your-family-actions-group-i-am-an-official-group-heading-criteria")
    end
  end
end
