require 'spec_helper'

describe CmaCase do
  subject { CmaCase.new(document_attributes) }
  let(:opened_date) { 1.year.ago.to_date }
  let(:closed_date) { 3.months.ago.to_date }
  let(:document_attributes) { {} }

  describe '#metadata' do
    context 'with all attributes' do
      let(:document_attributes) do
        {
          'case_type' => {
            'key' => 'mergers',
            'label' => 'Mergers',
          },
          'case_state' => {
            'key' => 'closed',
            'label' => 'Closed',
          },
          'market_sector' => {
            'key' => 'energy',
            'label' => 'Energy',
          },
          'outcome_type' => {
            'key' => 'mergers-phase-1-clearance',
            'label' => 'Mergers - phase 1 clearance',
          },
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
      let(:document_attributes) do
        {
          'case_type' => {
            'key' => 'mergers',
            'label' => 'Mergers',
          },
          'case_state' => {
            'key' => 'open',
            'label' => 'Open',
          },
          'market_sector' => {
            'key' => 'energy',
            'label' => 'Energy',
          },
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
      let(:document_attributes) do
        {
          'case_type' => {
            'key' => 'mergers',
            'label' => 'Mergers',
          },
          'case_state' => {
            'key' => 'open',
            'label' => 'Open',
          },
          'market_sector' => {
            'key' => 'energy',
            'label' => 'Energy',
          },
          'outcome_type' => {
            'key' => '',
            'label' => nil,
          },
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
