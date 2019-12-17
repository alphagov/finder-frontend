require "spec_helper"

RSpec.describe BrexitChecker::Criterion do
  describe "factories" do
    it "has a valid default factory" do
      criterion = FactoryBot.build(:brexit_checker_criterion)
      expect(criterion.valid?).to be(true)
    end
  end

  describe "#hash & #eql?" do
    let(:criterion1) { FactoryBot.build(:brexit_checker_criterion, key: "aero-space") }
    let(:criterion2) { FactoryBot.build(:brexit_checker_criterion, key: "aero-space") }
    let(:criterion3) { FactoryBot.build(:brexit_checker_criterion, key: "forestry") }

    it "correctly removes duplicates from an array by key" do
      expect([criterion1, criterion2, criterion3].uniq.map(&:key)).to eq(%w[aero-space forestry])
    end
  end
end
