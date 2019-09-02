require 'spec_helper'

describe Checklists::Action do
  describe '#show?' do
    let(:criteria_logic) do
      instance_double Checklists::CriteriaLogic, applies?: :result
    end

    it "delegates to the CriteriaLogic" do
      allow(Checklists::CriteriaLogic).to receive(:new)
        .with('criteria', 'selected_criteria') { criteria_logic }

      action = described_class.new('criteria' => 'criteria')
      expect(action.show?('selected_criteria')).to eq :result
    end
  end

  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of actions with required fields" do
      subject.each do |action|
        expect(action.id).to be_present
        expect(action.title).to be_present
        expect(%w[business citizen]).to include(action.audience)
        expect(action.consequence).to be_present
        expect(action.criteria).to be_a String
        expect(action.criteria).to be_present
        expect(action.priority).to be_a Integer
      end
    end

    it "returns actions that reference valid criteria" do
      all_criteria_keys = Checklists::Criterion.load_all.map(&:key)

      subject.each do |action|
        expect { action.show?([]) }.to_not raise_error
        expect { action.show?(all_criteria_keys) }.to_not raise_error
        expect(action.valid?).to be true
      end
    end

    it "returns actions with guidance fields together" do
      subject.each do |action|
        text = action.guidance_link_text.present?
        url = action.guidance_url.present?
        expect(text ^ url).to be_falsey
      end
    end

    it "returns actions with unique ids" do
      ids = subject.map(&:id)
      expect(ids.uniq.count).to eq(ids.count)
    end
  end
end
