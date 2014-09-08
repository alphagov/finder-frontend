require 'spec_helper'

describe DocumentParser do
  context "with a document hash" do
    let(:document_hash) {
      {
        "title" => "Private healthcare market investigation",
        "link" => "cma-cases/private-healthcare-market-investigation",
        "document_type" => "cma_case",
        "opened_date" => "2007-08-14",
        "closed_date" => "2008-03-01",
        "summary" => "Inquiry into the private healthcare market",

        "market_sector" => [{
          "value" => "pharmaceuticals",
          "label" => "Pharmaceuticals"
        }],
        "case_type" => [{
          "value" => "markets",
          "label" => "Markets"
        }],
        "outcome_type" => [{
          "value" => "ca98-infringement-chapter-i",
          "label" => "CA98 - infringement Chapter I"
        }],
        "case_state" => [{
          "value" => "closed",
          "label" => "Closed"
        }]
      }
    }
    subject { DocumentParser.parse(document_hash) }

    specify { subject.should be_a CmaCase }
    specify { subject.title.should == 'Private healthcare market investigation' }
    specify { subject.url.should == '/cma-cases/private-healthcare-market-investigation' }
    specify { subject.metadata.to_set.should == [
      { type: 'date', name: 'Opened', value: '2007-08-14' },
      { type: 'date', name: 'Closed', value: '2008-03-01' },
      { type: 'text', name: 'Case type', value: 'Markets' },
      { type: 'text', name: 'Case state', value: 'Closed' },
      { type: 'text', name: 'Outcome type', value: 'CA98 - infringement Chapter I' },
      { type: 'text', name: 'Market sector', value: 'Pharmaceuticals' }
    ].to_set }
  end
end
