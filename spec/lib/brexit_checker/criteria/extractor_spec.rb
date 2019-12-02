require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Extractor do
  describe "#expression_criteria" do
    subject(:expression_criteria) { described_class.expression_criteria(expression) }

    context "an empty criteria" do
      let(:expression) { [] }
      it { is_expected.to eq([].to_set) }
    end

    context "the criteira is an array of strings" do
      let(:expression) { %w(a b c) }
      it { is_expected.to eq(%w(a b c).to_set) }
    end

    context "the criteira holds an OR object" do
      let(:expression) { [{ "any_of": %w(a b c) }] }
      it { is_expected.to eq(%w(a b c).to_set) }
    end

    context "the criteira holds an AND object" do
      let(:expression) { [{ "all_of": %w(a b c) }] }
      it { is_expected.to eq(%w(a b c).to_set) }
    end

    context "the criteira holds an AND and OR object" do
      let(:expression) { [{ "any_of": %w(a b c) }, { "all_of": %w(d e f) }] }
      it { is_expected.to eq(%w(a b c d e f).to_set) }
    end

    context "the criteira holds an AND object and separate criteira" do
      let(:expression) { ["a", { "all_of": %w(d e f) }] }
      it { is_expected.to eq(%w(a d e f).to_set) }
    end

    context "the criteira holds an OR object and separate criteira" do
      let(:expression) { ["a", { "any_of": %w(d e f) }] }
      it { is_expected.to eq(%w(a d e f).to_set) }
    end
  end
end
