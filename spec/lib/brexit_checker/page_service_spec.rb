require "spec_helper"

describe BrexitChecker::PageService do
  let(:questions) {
    [
      FactoryBot.build(:brexit_checker_question),
      FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(a b) }]),
      FactoryBot.build(:brexit_checker_question, criteria: [{ "all_of" => %w(c d) }]),
      FactoryBot.build(:brexit_checker_question, criteria: %w(c))
    ]
  }

  describe "#next_page" do
    it "returns nil if the last page has been reached" do
      subject = BrexitChecker::PageService.new(questions: questions,
                                            current_page_from_params: questions.count,
                                            criteria_keys: [])
      expect(subject.next_page).to be nil
    end
    it "returns the next viewable page + 1 if in range" do
      subject = BrexitChecker::PageService.new(questions: questions,
                                            current_page_from_params: 0,
                                            criteria_keys: [])
      expect(subject.next_page).to be 1
    end
  end
  describe "#redirect_to_results?" do
    it "return true  if the end of the questions has been reached" do
      subject = BrexitChecker::PageService.new(questions: questions,
                                            current_page_from_params: questions.count,
                                            criteria_keys: [])
      expect(subject.redirect_to_results?).to be true
    end
    it "returns false if the end of the questions has not been reached" do
      subject = BrexitChecker::PageService.new(questions: questions,
                                            current_page_from_params: questions.count - 1,
                                            criteria_keys: %w[c])
      expect(subject.redirect_to_results?).to be false
    end
  end
  describe "#page" do
    let(:subject) {
      BrexitChecker::PageService.new(questions: questions, current_page_from_params: current_page_from_params, criteria_keys: criteria_keys).current_page
    }
    let(:criteria_keys) { [] }
    let(:current_page_from_params) { nil }

    context "the page on the form is 0" do
      let(:current_page_from_params) { 0 }
      it "returns the page from the form " do
        expect(subject).to eq(0)
      end
    end
    context "the page on the form is 1 and the criteria_keys match question_two" do
      let(:current_page_from_params) { 1 }
      let(:criteria_keys) { %w[c d] }
      it "returns the page for question_two" do
        expect(subject).to eq(2)
      end
    end
    context "the page on the form is 1 and the criteria_keys match question_three" do
      let(:current_page_from_params) { 1 }
      let(:criteria_keys) { %w[c] }
      it "returns the page for question_three" do
        expect(subject).to eq(3)
      end
    end
    context "the page on the form is 1 and the criteria_keys do not match anything" do
      let(:current_page_from_params) { 1 }
      let(:criteria_keys) { %w[e] }
      it "returns nil" do
        expect(subject).to be nil
      end
    end
    context "the page on the form is higher than the number of questions" do
      let(:current_page_from_params) { questions.count + 1 }
      it "returns nil" do
        expect(subject).to be nil
      end
    end
  end
end
