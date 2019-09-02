require 'spec_helper'

describe Checklists::Criterion do
  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of criteria with required fields" do
      subject.each do |criterion|
        expect(criterion.key).to be_present
        expect(criterion.text).to be_present
      end
    end

    it "returns criteria with unique keys" do
      keys = subject.map(&:key)
      expect(keys.uniq.count).to eq(keys.count)
    end

    it "returns criteria that reference valid criteria" do
      keys = Checklists::Criterion.load_all.map(&:key)

      subject.each do |criterion|
        expect(keys).to include(*criterion.depends_on.to_a)
      end
    end

    it "returns criteria that are covered by a question" do
      possible_criteria = Checklists::Question.load_all
        .flat_map(&:possible_values)

      subject.each do |criterion|
        expect(possible_criteria).to include(criterion.key)
      end
    end
  end
end
