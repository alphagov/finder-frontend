require 'spec_helper'

describe Checklists::Question do
  describe '#show?' do
    let(:criteria) { [] }
    subject { described_class.new('depends_on' => dependencies).show?(criteria) }

    context "when the question has no dependencies" do
      let(:dependencies) { [] }

      it { is_expected.to eq(true) }
    end

    context "when the question has unmet dependencies" do
      let(:dependencies) { %w[A] }

      it { is_expected.to eq(false) }
    end

    context "when the question has met dependencies" do
      let(:criteria) { %w[A B] }
      let(:dependencies) { %w[A B] }

      it { is_expected.to eq(true) }
    end
  end

  describe ".load_all" do
    subject { described_class.load_all }

    it "returns a list of questions with required fields" do
      subject.each do |question|
        expect(question.key).to be_present
        expect(question.text).to be_present
        expect(%w[single multiple single_wrapped]).to include(question.type)
        expect(question.options).to be_a Array
      end
    end

    it "returns questions with unique keys" do
      keys = subject.map(&:key)
      expect(keys.uniq.count).to eq(keys.count)
    end

    it "returns questions that reference valid criteria" do
      criteria = Checklists::Criterion.load_all.map(&:key)

      subject.each do |question|
        question.options.each do |option|
          expect(criteria).to include(option['value'])
        end

        expect(criteria).to include(*question.depends_on.to_a)
      end
    end
  end
end
