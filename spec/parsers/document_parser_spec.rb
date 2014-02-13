require 'spec_helper'

describe DocumentParser do
  context "with a document hash" do
    let(:document_hash) {
      {
        'title' => 'Private healthcare market investigation',
        'url' => '/cma-cases/private-healthcare-market-investigation',
        'metadata' => [
          { 'type' => 'date', 'name' => 'date_referred', 'value' => '2007-08-14' },
          { 'type' => 'text', 'name' => 'case_type', 'value' => 'Market investigation' }
        ]
      }
    }
    subject { DocumentParser.parse(document_hash) }

    specify { subject.should be_a Document }
    specify { subject.title.should == 'Private healthcare market investigation' }
    specify { subject.url.should == '/cma-cases/private-healthcare-market-investigation' }
    specify { subject.metadata.should == [
      { type: 'date', name: 'date_referred', value: '2007-08-14' },
      { type: 'text', name: 'case_type', value: 'Market investigation' }
    ] }
  end
end
