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

  describe ".link_params_without_facet_value" do
    it "should remove a string value" do
      helper.stub(:params) { { "first_key" => ["one", "two"], "second_key" => "three" } }
      helper.link_params_without_facet_value('second_key', 'three').should == { "first_key" => ["one", "two"] }
    end

    it "should remove a array value" do
      helper.stub(:params) { { "first_key" => ["one", "two"], "second_key" => "three" } }
      helper.link_params_without_facet_value('first_key', 'two').should == { "first_key" => ["one"], "second_key" => "three" }
    end

    it "should remove an array of one item" do
      helper.stub(:params) { { "first_key" => ["one"], "second_key" => "three" } }
      helper.link_params_without_facet_value('first_key', 'one').should == { "second_key" => "three" }
    end
  end

  describe ".facet_values_sentence" do
    let(:allowed_values) { [
      OpenStruct.new(label: "Allowed value 1", value: "allowed-value-1"),
      OpenStruct.new(label: "Allowed value 2", value: "allowed-value-2")
    ] }

    it "should use the facet preposition to create a sentence" do
      helper.stub(:params) { { "facet_key" => 'value' } }
      helper.stub(:url_for).with({})

      facet = SelectFacet.new(preposition: 'my-prepl', key: 'facet_key', allowed_values: allowed_values, value: [ 'allowed-value-1' ])
      helper.facet_values_sentence(facet).should == '<strong>Allowed value 1 <a>×</a></strong>'
    end
  end
end
