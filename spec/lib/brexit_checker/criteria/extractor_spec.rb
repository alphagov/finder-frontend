require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Extractor do
  describe "#extract" do
    subject { described_class.extract(expression) }

    context "an empty criteria" do
      let(:expression) { [] }
      it { is_expected.to match_array([]) }
    end

    context "the criteira is an array of strings" do
      let(:expression) { %w(a b c) }
      it { is_expected.to match_array(%w(a b c)) }
    end

    context "the criteira holds an OR object" do
      let(:expression) { [{ "any_of": %w(a b c) }] }
      it { is_expected.to match_array(%w(a b c)) }
    end

    context "the criteira holds an AND object" do
      let(:expression) { [{ "all_of": %w(a b c) }] }
      it { is_expected.to match_array(%w(a b c)) }
    end

    context "the criteira holds an AND and OR object" do
      let(:expression) { [{ "any_of": %w(a b c) }, { "all_of": %w(d e f) }] }
      it { is_expected.to match_array(%w(a b c d e f)) }
    end

    context "the criteira holds an AND object and separate criteira" do
      let(:expression) { ["a", { "all_of": %w(d e f) }] }
      it { is_expected.to match_array(%w(a d e f)) }
    end

    context "the criteira holds an OR object and separate criteira" do
      let(:expression) { ["a", { "any_of": %w(d e f) }] }
      it { is_expected.to match_array(%w(a d e f)) }
    end
  end
end
