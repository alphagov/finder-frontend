require "spec_helper"

describe ApplicationHelper, type: :helper do
  describe ".input_checked" do
    it "should find a match in an array" do
      allow(helper).to receive(:params).and_return("my_key" => %w(one two))
      expect(helper.input_checked("my_key", "one")).to eql(' checked="checked"')
      expect(helper.input_checked("my_key", "two")).to eql(' checked="checked"')
      expect(helper.input_checked("my_key", "three")).to be_nil
    end

    it "should find a match in string" do
      allow(helper).to receive(:params).and_return("my_key" => "one")
      expect(helper.input_checked("my_key", "one")).to eql(' checked="checked"')
      expect(helper.input_checked("my_key", "two")).to be_nil
    end
  end
end
