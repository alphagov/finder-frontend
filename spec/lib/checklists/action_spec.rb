require 'spec_helper'

describe Checklists::Action do
  describe '#criteria?' do
    subject do
      described_class.new(
        'criteria' => criteria
      ).applies_to?(selected_criteria)
    end

    context "no applicable criteria" do
      let(:criteria) { [] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(false) }
    end

    context "the selected criteria meets the applicable criteria" do
      let(:criteria) { %w[A B C] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(true) }
    end

    context "no selected criteria" do
      let(:criteria) { %w[A B C] }
      let(:selected_criteria) { [] }

      it { is_expected.to eq(false) }
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
        expect(action.title_url).to be_present
        expect(action.criteria).to be_a Array
      end
    end

    it "returns actions that reference valid criteria" do
      criteria = Checklists::Criterion.load_all.map(&:key)

      subject.each do |action|
        expect(criteria).to include(*action.criteria.to_a)
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

    it "does not return soft deleted actions by default" do
      all_actions = described_class.load_all(exclude_deleted: false)
      expect(subject.count).to be < all_actions.count
    end
  end
end
