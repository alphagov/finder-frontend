require 'spec_helper'

RSpec.describe Checklists::CriteriaPathService do
  context 'there are questions' do
    let(:questions) do
      one = Checklists::Question.new('key' => 'question_one',
                                     'options' => [{ 'value' => 'A' }, { 'value' => 'B' }])
      two = Checklists::Question.new('key' => 'question_two',
                                     'options' => [{ 'value' => 'C' }, { 'value' => 'D' }],
                                     'criteria' => 'A')
      three = Checklists::Question.new('key' => 'question_three',
                                       'options' => [{ 'value' => 'E' }, { 'value' => 'F' }],
                                       'criteria' => 'A && C')
      [one, two, three]
    end

    subject(:subject) { Checklists::CriteriaPathService.new(questions) }

    before :each do
      allow(Checklists::Criterion).to receive(:load_all).and_return([Checklists::Criterion.new('key' => 'A'),
                                                                     Checklists::Criterion.new('key' => 'B'),
                                                                     Checklists::Criterion.new('key' => 'C'),
                                                                     Checklists::Criterion.new('key' => 'D'),
                                                                     Checklists::Criterion.new('key' => 'E'),
                                                                     Checklists::Criterion.new('key' => 'F')])
    end
    it 'returns no used criteria' do
      expect(subject.used_criteria([])).to eq([])
    end
    it 'returns one used criterion' do
      expect(subject.used_criteria(%w[B])).to eq(%w[B])
    end
    it 'returns one criterion from the correct path, ignoring the one from a previously selected path' do
      expect(subject.used_criteria(%w(B C))).to eq(%w[B])
    end
    it 'returns thee criteria from the correct path' do
      expect(subject.used_criteria(%w(A C E))).to eq(%w(A C E))
    end
    it 'does not care about the order of criteria inputted' do
      expect(subject.used_criteria(%w(C E F A))).to eq(%w(A C E F))
    end
    it 'handles unfinished paths' do
      expect(subject.used_criteria(%w(C A))).to eq(%w(A C))
    end
  end
end
