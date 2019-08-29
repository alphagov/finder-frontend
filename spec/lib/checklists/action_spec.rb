require 'spec_helper'

describe Checklists::Action do
  describe '#criteria?' do
    before do
      allow(Checklists::Criterion).to receive(:load_all).and_return([
        double(key: 'a'), double(key: 'b'), double(key: 'c')
      ])
    end

    subject do
      described_class.new(
        'criteria' => criteria
      ).applies_to?(selected_criteria)
    end

    context "an empty criteria" do
      let(:criteria) { "" }
      let(:selected_criteria) { %w[a] }

      it { is_expected.to eq(false) }
    end

    context "a nil criteria" do
      let(:criteria) { nil }
      let(:selected_criteria) { %w[a] }

      it { is_expected.to eq(false) }
    end

    context "the selected criteria meets the applicable criteria" do
      let(:criteria) { "a || b || c" }
      let(:selected_criteria) { %w[a] }

      it { is_expected.to eq(true) }
    end

    context "the selected criteria meets the applicable criteria with an AND" do
      let(:criteria) { "a && b || c" }
      let(:selected_criteria) { %w[a b] }

      it { is_expected.to eq(true) }
    end

    context "the selected criteria doesn't meet the applicable criteria with an AND" do
      let(:criteria) { "a && (b || c)" }
      let(:selected_criteria) { %w[c] }

      it { is_expected.to eq(false) }
    end

    context "no selected criteria" do
      let(:criteria) { "a || b || c" }
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
        expect(action.criteria).to be_a String
        expect(action.priority).to be_a Integer
      end
    end

    it "returns actions that reference valid criteria" do
      subject.each do |action|
        expect(action.applies_to?([])).to eq(false)
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
