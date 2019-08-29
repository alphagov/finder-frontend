RSpec.describe Checklists::CriteriaLogic do
  describe '#applies?' do
    before do
      allow(Checklists::Criterion).to receive(:load_all).and_return([
        double(key: 'a'), double(key: 'b'), double(key: 'c')
      ])
    end

    subject do
      described_class.new(criteria, selected_criteria).applies?
    end

    context "a nil criteria" do
      let(:criteria) { nil }
      let(:selected_criteria) { %w[a] }

      it { is_expected.to eq(true) }
    end

    context "an empty criteria" do
      let(:criteria) { "" }
      let(:selected_criteria) { %w[a] }

      it { is_expected.to eq(true) }
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
end
