require 'spec_helper'

describe ApplicationHelper do
  describe ".document_metadata_for" do
    let(:document) { Document.new(metadata: metadata) }
    subject {
      Nokogiri::HTML::DocumentFragment.parse(helper.document_metadata_for(document)).children.first
    }


    context "with a document with text metadata" do
      let(:metadata) { [
        { type: 'text', name: 'case type', value: 'Merger inquiry' },
        { type: 'text', name: 'document status', value: 'Archived' }
      ] }

      it "should render a dl with dt and dd as name and value respectively" do
        subject.name.should == 'dl'

        subject.children[0].name.should == 'dt'
        subject.children[0].text.should == 'case type'
        subject.children[1].name.should == 'dd'
        subject.children[1].text.should == 'Merger inquiry'

        subject.children[2].name.should == 'dt'
        subject.children[2].text.should == 'document status'
        subject.children[3].name.should == 'dd'
        subject.children[3].text.should == 'Archived'
      end
    end

    context "with date type metadata" do
      let(:metadata) { [
        { type: 'date', name: 'published on', value: '2003-12-30' }
      ] }

      it "should render the date as a long form date" do
        subject.children[1].text.should == '30 December 2003'
      end
    end
  end
end
