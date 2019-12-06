require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Validator do
  before do
    allow(BrexitChecker::Criterion).to receive(:load_all).and_return([
      double(key: "a"), double(key: "b"), double(key: "c")
    ])
  end

  subject { described_class.validate(expression) }

  context "a nil criteria" do
    let(:expression) { nil }
    it { is_expected.to eq(true) }
  end

  context "the criteria includes all the available criteria" do
    let(:expression) { [{ "any_of" => %w(a b c) }] }
    it { is_expected.to eq(true) }
  end

  context "the criteria references a non-existent criteria" do
    let(:expression) { [{ "any_of" => %w(a b c) }, { "all_of" => %w(d) }] }
    it { is_expected.to eq(false) }
  end
end
