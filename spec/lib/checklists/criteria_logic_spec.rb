require 'spec_helper'

RSpec.describe Checklists::CriteriaLogic do
  before do
    allow(described_class).to receive(:all_options).and_return(%w(a b c))
    allow(described_class).to receive(:all_options_hash).and_return("a" => false, "b" => false, "c" => false)
  end

  let(:selected_criteria) { [] }

  subject(:criteria_logic) do
    described_class.new(criteria, selected_criteria)
  end

  describe '#valid?' do
    subject { criteria_logic.valid? }

    context "a nil criteria" do
      let(:criteria) { nil }
      it { is_expected.to eq(true) }
    end

    context "the criteria includes all the available criteria" do
      let(:criteria) { "a || b || c" }
      it { is_expected.to eq(true) }
    end

    context "the criteria references a non-existent criteria" do
      let(:criteria) { "a || b || c || d" }
      it { is_expected.to eq(false) }
    end
  end

  describe '#applies?' do
    subject { criteria_logic.applies? }

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
