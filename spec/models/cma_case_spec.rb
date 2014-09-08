require 'spec_helper'

describe CmaCase do
  subject { CmaCase.new(document_attributes) }
  let(:opened_date) { 1.year.ago.to_date }
  let(:closed_date) { 3.months.ago.to_date }
  let(:document_attributes) { base_attributes.merge(extra_attributes) }
  let(:base_attributes) { {
    title: "A CMA Case",
    link: "cma-cases/a-cma-case",
  } }
  let(:extra_attributes) { {} }

  describe '#metadata' do
    context 'with all attributes' do
      let(:extra_attributes) do
        {
          'case_type' => [{
            'value' => 'mergers',
            'label' => 'Mergers',
          }],
          'case_state' => [{
            'value' => 'closed',
            'label' => 'Closed',
          }],
          'market_sector' => [{
            'value' => 'energy',
            'label' => 'Energy',
          }],
          'outcome_type' => [{
            'value' => 'mergers-phase-1-clearance',
            'label' => 'Mergers - phase 1 clearance',
          }],
          'opened_date' => opened_date,
          'closed_date' => closed_date,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Case type',
            value: 'Mergers',
            type: 'text',
          },
          {
            name: 'Case state',
            value: 'Closed',
            type: 'text',
          },
          {
            name: 'Market sector',
            value: 'Energy',
            type: 'text',
          },
          {
            name: 'Outcome type',
            value: 'Mergers - phase 1 clearance',
            type: 'text',
          },
          {
            name: 'Opened',
            value: opened_date,
            type: 'date',
          },
          {
            name: 'Closed',
            value: closed_date,
            type: 'date',
          },
        ]
      end
    end

    context 'with missing attributes' do
      let(:extra_attributes) do
        {
          'case_type' => [{
            'value' => 'mergers',
            'label' => 'Mergers',
          }],
          'case_state' => [{
            'value' => 'open',
            'label' => 'Open',
          }],
          'market_sector' => [{
            'value' => 'energy',
            'label' => 'Energy',
          }],
          'opened_date' => opened_date,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Case type',
            value: 'Mergers',
            type: 'text',
          },
          {
            name: 'Case state',
            value: 'Open',
            type: 'text',
          },
          {
            name: 'Market sector',
            value: 'Energy',
            type: 'text',
          },
          {
            name: 'Opened',
            value: opened_date,
            type: 'date',
          },
        ]
      end
    end

    context 'with empty attributes' do
      let(:extra_attributes) do
        {
          'case_type' => [{
            'value' => 'mergers',
            'label' => 'Mergers',
          }],
          'case_state' => [{
            'value' => 'open',
            'label' => 'Open',
          }],
          'market_sector' => [{
            'value' => 'energy',
            'label' => 'Energy',
          }],
          'outcome_type' => [{
            'value' => nil,
            'label' => nil,
          }],
          'opened_date' => opened_date,
          'closed_date' => nil,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Case type',
            value: 'Mergers',
            type: 'text',
          },
          {
            name: 'Case state',
            value: 'Open',
            type: 'text',
          },
          {
            name: 'Market sector',
            value: 'Energy',
            type: 'text',
          },
          {
            name: 'Opened',
            value: opened_date,
            type: 'date',
          },
        ]
      end
    end
  end
end
