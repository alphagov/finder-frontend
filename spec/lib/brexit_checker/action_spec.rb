require "spec_helper"

RSpec.describe BrexitChecker::Action do
  let(:subject) {
    BrexitChecker::Action.new(id: "1",
                              title: "1",
                              consequence: "1",
                              audience: "business",
                              priority: "1",
                              criteria: criteria)
  }
  describe "#all_criteria" do
    describe "empty criteria" do
      let(:criteria) { [] }
      it "cannot have empty criteria" do
        expect { subject.all_criteria }.to raise_error(ActiveModel::ValidationError)
      end
    end
    describe "one criterion" do
      let(:criteria) { %w[my_criterion] }
      it "returns the criterion" do
        expect(subject.all_criteria).to eq(%w[my_criterion])
      end
    end

    describe "multiple nested criteria" do
      let(:criteria) {
        {
          "any_of" => [
            { "all_of" => [{ "any_of" => %w[import-from-eu export-to-eu] }, "chemical"] },
            "non-metal-material",
          ],
        }
      }
      it "returns all criteria strings in the hash" do
        expect(subject.all_criteria).to match_array(%w[import-from-eu export-to-eu chemical non-metal-material])
      end
    end
  end
end
