require 'spec_helper'

describe AaibReport do
  subject { AaibReport.new(document_attributes) }
  let(:date_of_occurrence) { 1.year.ago.to_date }
  let(:document_attributes) { {} }

  describe '#metadata' do
    context 'with all attributes' do
      let(:document_attributes) do
        {
          'aircraft_category' => {
            'key' => 'commercial-fixed-wing',
            'label' => 'Commercial - fixed wing',
          },
          'report_type' => {
            'key' => 'annual-safety-reports',
            'label' => 'Annual safety reports',
          },
          'date_of_occurrence' => date_of_occurrence,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Aircraft category',
            value: 'Commercial - fixed wing',
            type: 'text',
          },
          {
            name: 'Report type',
            value: 'Annual safety reports',
            type: 'text',
          },
          {
            name: 'Occurred',
            value: date_of_occurrence,
            type: 'date',
          },
        ]
      end
    end

    context 'with missing attributes' do
      let(:document_attributes) do
        {
          'aircraft_category' => {
            'key' => 'commercial-fixed-wing',
            'label' => 'Commercial - fixed wing',
          },
          'date_of_occurrence' => date_of_occurrence,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Aircraft category',
            value: 'Commercial - fixed wing',
            type: 'text',
          },
          {
            name: 'Occurred',
            value: date_of_occurrence,
            type: 'date',
          },
        ]
      end
    end

    context 'with empty attributes' do
      let(:document_attributes) do
        {
          'aircraft_category' => {
            'key' => 'commercial-fixed-wing',
            'label' => 'Commercial - fixed wing',
          },
          'report_type' => {
            'key' => '',
            'label' => nil,
          },
          'date_of_occurrence' => nil,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Aircraft category',
            value: 'Commercial - fixed wing',
            type: 'text',
          },
        ]
      end
    end
  end
end
