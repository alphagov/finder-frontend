require 'spec_helper'

describe ChecklistHelper, type: :helper do
  describe "#next_viewable_page" do
    let(:page) { 1 }
    let(:criteria_keys) { [1, 2, 3] }
    let(:questions) do
      [
        Checklists::Question.new('depends_on' => [1, 2, 3]),
        Checklists::Question.new('depends_on' => [1, 2, 3]),
        Checklists::Question.new('depends_on' => [1, 2, 3])
      ]
    end

    subject { next_viewable_page(page, questions, criteria_keys) }

    context "when its the first page and the question is not dependent" do
      it { is_expected.to eq(1) }
    end

    context "when the question's criteria are not met" do
      it 'returns the next page' do
        questions[0] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(2)
      end
    end

    context "when consecutive questions' criteria are not met" do
      it 'returns the page number of first applicable question' do
        questions[0] = Checklists::Question.new('depends_on' => [4])
        questions[1] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(3)
      end
    end

    context "when its the last page and question's criteria are not met" do
      let(:page) { 3 }

      it 'returns the next page' do
        questions[2] = Checklists::Question.new('depends_on' => [4])
        expect(subject).to eq(4)
      end
    end
  end
end
