require "spec_helper"

describe UTF8Cleaner do
  describe "#cleaned" do
    it "removes any invalid UTF-8 characters from a string" do
      string_to_be_cleaned = "Hello,\255 world".force_encoding('UTF-8')

      cleaned = UTF8Cleaner.new(string_to_be_cleaned).cleaned

      expect{ cleaned }.not_to raise_error
      expect(cleaned).to eql("Hello, world")
    end

    it "returns nil if there are no valid UTF-8 characters in a string" do
      string_to_be_cleaned = "\255".force_encoding('UTF-8')

      cleaned = UTF8Cleaner.new(string_to_be_cleaned).cleaned

      expect(cleaned).to be_nil
    end

    it "returns nil if nil is passed in" do
      string_to_be_cleaned = nil

      cleaned = UTF8Cleaner.new(string_to_be_cleaned).cleaned

      expect(cleaned).to be_nil
    end

    it "does not touch valid UTF-8 strings" do
      string_to_be_cleaned = "Hello, world".force_encoding('UTF-8')

      cleaned = UTF8Cleaner.new(string_to_be_cleaned).cleaned

      expect(cleaned).to eql("Hello, world")
    end

    it "does not touch valid multi-byte UTF-8 characters in a string" do
      string_to_be_cleaned = "Hello,\255 world 😀".force_encoding('UTF-8')

      cleaned = UTF8Cleaner.new(string_to_be_cleaned).cleaned

      expect(cleaned).to eql("Hello, world 😀")
    end
  end
end
