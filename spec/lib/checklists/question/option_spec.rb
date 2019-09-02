require 'spec_helper'

RSpec.describe Checklists::Question::Option do
  describe "#show?" do
    let(:criteria_logic) do
      instance_double Checklists::CriteriaLogic, applies?: :result
    end

    before do
      allow(Checklists::CriteriaLogic).to receive(:new)
        .with("criteria", []) { criteria_logic }
    end

    it "delegates to CriteriaLogic" do
      option = described_class.new("criteria" => "criteria")
      expect(option.show?([])).to eq(:result)
    end
  end
end
