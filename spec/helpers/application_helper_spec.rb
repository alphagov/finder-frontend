require 'spec_helper'

describe ApplicationHelper do
  describe ".document_metadata_value" do
    let(:document) { Document.new(metadata: metadata) }
    subject {
      helper.document_metadata_value(document.metadata.first[:value], document.metadata.first[:type])
    }

    context "with date type metadata" do
      let(:metadata) { [
        { type: 'date', name: 'published on', value: '2003-12-30' }
      ] }

      it "should render the date as a long form date" do
        subject.should == '30 December 2003'
      end
    end
  end

  describe ".input_checked" do
    it "should find a match in an array" do
      helper.stub(:params) { { "my_key" => [ 'one', 'two'] } }
      helper.input_checked('my_key', 'one').should == ' checked="checked"'
      helper.input_checked('my_key', 'two').should == ' checked="checked"'
      helper.input_checked('my_key', 'three').should == nil
    end

    it "should find a match in string" do
      helper.stub(:params) { { "my_key" => 'one' } }
      helper.input_checked('my_key', 'one').should == ' checked="checked"'
      helper.input_checked('my_key', 'two').should == nil
    end
  end
end
