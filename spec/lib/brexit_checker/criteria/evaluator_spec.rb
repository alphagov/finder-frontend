require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Evaluator do
  let(:selected_criteria) { [] }
  subject(:evaluation) { described_class.evaluate(expression, selected_criteria) }

  context "a nil criteria" do
    let(:expression) { nil }
    let(:selected_criteria) { %w[a] }

    it { is_expected.to eq(true) }
  end

  context "an empty criteria" do
    let(:expression) { [] }
    let(:selected_criteria) { %w[a] }

    it { is_expected.to eq(true) }
  end

  context "the selected criteria meets the applicable criteria" do
    let(:expression) { [{ "any_of" => %w(a b c) }] }
    let(:selected_criteria) { %w[a] }

    it { is_expected.to eq(true) }
  end

  context "the selected criteria meets the applicable criteria with an AND" do
    let(:expression) { ["a", { "any_of" => %w(b c) }] }
    let(:selected_criteria) { %w[a b] }

    it { is_expected.to eq(true) }
  end

  context "the selected criteria doesn't meet the applicable criteria with an AND" do
    let(:expression) { ["a", { "any_of" => %w(b c) }] }
    let(:selected_criteria) { %w[c] }

    it { is_expected.to eq(false) }
  end

  context "no selected criteria" do
    let(:expression) { [{ "any_of" => %w(a b c) }] }
    let(:selected_criteria) { [] }

    it { is_expected.to eq(false) }
  end
end
