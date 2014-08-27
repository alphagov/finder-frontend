require 'spec_helper'

describe MedicalSafetyAlert do
  subject { MedicalSafetyAlert.new(document_attributes) }
  let(:published_at) { 1.year.ago.to_date }
  let(:document_attributes) { {} }

  describe '#metadata' do
    context 'with all attributes' do
      let(:document_attributes) do
        {
          'alert_type' => [{
            'value' => 'drugs',
            'label' => 'Drugs',
          }],
          'medical_specialism' => [{
            'value' => 'dentistry',
            'label' => 'Dentistry',
          }],
          'published_at' => published_at,
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Alert type',
            value: 'Drugs',
            type: 'text',
          },
          {
            name: 'Medical specialism',
            value: 'Dentistry',
            type: 'text',
          },
          {
            name: 'Published',
            value: published_at,
            type: 'date',
          },
        ]
      end
    end

    context 'with missing attributes' do
      let(:document_attributes) do
        {}
      end

      specify do
        subject.metadata.should == []
      end
    end

    context 'with empty attributes' do
      let(:document_attributes) do
        {
          'alert_type' => [{
            'value' => nil,
            'label' => nil,
          }],
          'medical_specialism' => [{
            'value' => nil,
            'label' => nil,
          }],
          'published_at' => nil,
        }
      end

      specify do
        subject.metadata.should == []
      end
    end
  end
end
