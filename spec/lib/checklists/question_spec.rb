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
end
