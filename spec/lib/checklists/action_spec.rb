require 'spec_helper'

describe Checklists::Action do
  describe '#applies_to?' do
    let(:criteria_logic) do
      instance_double Checklists::CriteriaLogic, applies?: :result
    end

    it "delegates to the CriteriaLogic" do
      allow(Checklists::CriteriaLogic).to receive(:new)
        .with('criteria', 'selected_criteria') { criteria_logic }

      action = described_class.new('criteria' => 'criteria')
      expect(action.applies_to?('selected_criteria')).to eq :result
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
      subject.each do |action|
        expect { action.applies_to?([]) }.to_not raise_error
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

    # it "does not return soft deleted actions by default" do
    #   all_actions = described_class.load_all(exclude_deleted: false)
    #   expect(subject.count).to be < all_actions.count
    # end
  end
end
