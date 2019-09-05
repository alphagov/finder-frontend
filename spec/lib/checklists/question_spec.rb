require 'spec_helper'

describe Checklists::Question do
  describe '#show?' do
    it "delegates to the CriteriaLogic" do
      expect(Checklists::CriteriaLogic::Evaluator).to receive(:evaluate)
        .with('criteria', 'selected_criteria')
        .and_return(:result)

      question = described_class.new('criteria' => 'criteria')
      expect(question.show?('selected_criteria')).to eq(:result)
    end
  end

  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of questions with required fields" do
      subject.each do |question|
        expect(question.key).to be_present
        expect(question.text).to be_present
        expect(%w[single single_wrapped multiple multiple_grouped]).to include(question.type)
        expect(question.options).to be_a Array
      end
    end

    it "returns questions with unique keys" do
      keys = subject.map(&:key)
      expect(keys.uniq.count).to eq(keys.count)
    end

    it "returns questions that reference valid criteria" do
      validator = Checklists::CriteriaLogic::Validator

      subject.each do |question|
        expect(validator.validate(question.criteria)).to be_truthy

        question.possible_values.each do |value|
          expect(validator.validate([value])).to be_truthy
        end
      end
    end
  end
end
