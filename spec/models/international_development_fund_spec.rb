require 'spec_helper'

describe InternationalDevelopmentFund do
  subject { InternationalDevelopmentFund.new(document_attributes) }
  let(:document_attributes) { {} }

  describe '#metadata' do
    context 'with all attributes' do
      let(:document_attributes) do
        {
          'application_state' => [{
            'value' => 'closed',
            'label' => 'Closed',
          }],
          'location' => [{
            'value' => 'afghanistan',
            'label' => 'Afghanistan',
          }],
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Application state',
            value: 'Closed',
            type: 'text',
          },
          {
            name: 'Location',
            value: 'Afghanistan',
            type: 'text',
          },
        ]
      end
    end

    context 'with missing attributes' do
      let(:document_attributes) do
        {
          'application_state' => [{
            'value' => 'open',
            'label' => 'Open',
          }],
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Application state',
            value: 'Open',
            type: 'text',
          },
        ]
      end
    end

    context 'with empty attributes' do
      let(:document_attributes) do
        {
          'application_state' => [{
            'value' => 'open',
            'label' => 'Open',
          }],
          'location' => [{
            'value' => nil,
            'label' => nil,
          }],
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Application state',
            value: 'Open',
            type: 'text',
          },
        ]
      end
    end
  end
end
