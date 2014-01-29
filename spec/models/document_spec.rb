require 'spec_helper'

describe Document do
  describe '.from_hash' do
    let(:document_hash) {
      {
        'title' => 'Private healthcare market investigation',
        'metadata' => [
          { 'type' => 'date', 'name' => 'date_referred', 'value' => '2007-08-14' },
          { 'type' => 'text', 'name' => 'case_type', 'value' => 'Market investigation' }
        ]
      }
    }
    subject { Document.from_hash(document_hash) }

    specify { subject.title.should == 'Private healthcare market investigation' }
    specify { subject.metadata.should == [
      { type: 'date', name: 'date_referred', value: '2007-08-14' },
      { type: 'text', name: 'case_type', value: 'Market investigation' }
    ] }
  end
end
