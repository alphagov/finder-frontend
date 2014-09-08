require 'spec_helper'

describe InternationalDevelopmentFund do
  subject { InternationalDevelopmentFund.new(document_attributes) }
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
          'fund_state' => [{
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
            name: 'Fund state',
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
      let(:extra_attributes) do
        {
          'fund_state' => [{
            'value' => 'open',
            'label' => 'Open',
          }],
        }
      end

      specify do
        subject.metadata.should == [
          {
            name: 'Fund state',
            value: 'Open',
            type: 'text',
          },
        ]
      end
    end

    context 'with empty attributes' do
      let(:extra_attributes) do
        {
          'fund_state' => [{
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
            name: 'Fund state',
            value: 'Open',
            type: 'text',
          },
        ]
      end
    end
  end
end
