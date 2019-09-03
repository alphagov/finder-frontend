require 'spec_helper'

RSpec.describe Checklists::Question::Option do
  describe "#show?" do
    it "delegates to the CriteriaLogic" do
      expect(Checklists::CriteriaLogic::Evaluator).to receive(:evaluate)
        .with('criteria', 'selected_criteria')
        .and_return(:result)

      option = described_class.new('criteria' => 'criteria')
      expect(option.show?('selected_criteria')).to eq(:result)
    end
  end
end
