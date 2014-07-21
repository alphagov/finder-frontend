require 'spec_helper'

describe ApplicationHelper do

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
