require "spec_helper"

RSpec.describe BrexitChecker::Criteria::Parser do
  let(:input) { nil }
  subject(:output) { described_class.parse(input) }

  context "with a single identifier" do
    let(:input) { "a" }
    it { is_expected.to eq(%w[a]) }
  end

  context "with an AND operator" do
    let(:input) { "a AND b" }
    it { is_expected.to eq(["all_of" => %w[a b]]) }
  end

  context "with an OR operator" do
    let(:input) { "a OR b" }
    it { is_expected.to eq(["any_of" => %w[a b]]) }
  end

  context "with parenthesis" do
    let(:input) { "a OR (b AND c)" }
    it { is_expected.to eq(["any_of" => ["a", { "all_of" => %w[b c] }]]) }
  end

  context "with nested parenthesis" do
    let(:input) { "a OR (b AND (c OR d))" }
    it { is_expected.to eq(["any_of" => ["a", { "all_of" => ["b", { "any_of" => %w[c d] }] }]]) }
  end

  context "with more than two operands" do
    let(:input) { "a OR b OR c" }
    it { is_expected.to eq(["any_of" => %w[a b c]]) }
  end

  context "with ambigious combinations of operators" do
    context "and OR comes first" do
      let(:input) { "a OR b OR c AND d" }
      it { is_expected.to eq(["all_of" => [{ "any_of" => %w[a b c] }, "d"]]) }
    end

    context "and AND comes first" do
      let(:input) { "a AND b AND c OR d" }
      it { is_expected.to eq(["any_of" => [{ "all_of" => %w[a b c] }, "d"]]) }
    end
  end

  context "with invalid input" do
    context "with nil" do
      let(:input) { nil }

      it "should raise an exception" do
        expect { subject }.to raise_error(TypeError)
      end
    end

    context "with empty" do
      let(:input) { "" }

      it "should raise an exception" do
        expect { subject }.to raise_error(/Unexpected end/)
      end
    end

    context "with missing parenthesis" do
      let(:input) { "a OR (b AND c" }

      it "should raise an exception" do
        expect { subject }.to raise_error(/Unexpected end/)
      end
    end

    context "with two operators" do
      let(:input) { "a OR AND c" }

      it "should raise an exception" do
        expect { subject }.to raise_error(/Unknown operand/)
      end
    end
  end
end
