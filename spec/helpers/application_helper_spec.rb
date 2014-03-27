require 'spec_helper'

describe ApplicationHelper do
  describe ".document_metadata_value" do
    subject {
      helper.document_metadata_value('2003-12-30', 'date')
    }

    context "with date type metadata" do
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
