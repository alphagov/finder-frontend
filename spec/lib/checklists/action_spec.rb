require 'spec_helper'

describe Checklists::Action do
  describe '#applicable_criteria?' do
    subject do
      described_class.new(
        'applicable_criteria' => applicable_criteria
      ).applies_to?(selected_criteria)
    end

    context "no applicable criteria" do
      let(:applicable_criteria) { [] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(false) }
    end

    context "the selected criteria meets the applicable criteria" do
      let(:applicable_criteria) { %w[A B C] }
      let(:selected_criteria) { %w[A] }

      it { is_expected.to eq(true) }
    end

    context "no selected criteria" do
      let(:applicable_criteria) { %w[A B C] }
      let(:selected_criteria) { [] }

      it { is_expected.to eq(false) }
    end
  end
end
