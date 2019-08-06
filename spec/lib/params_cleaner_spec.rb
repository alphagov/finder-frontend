require "spec_helper"

describe ParamsCleaner do
  describe "#cleaned" do
    it "makes an array of a array-like hash" do
      params = { "foo" => { "0" => "bar", "1" => "baz" } }

      cleaned = ParamsCleaner.new(params).cleaned

      expect(cleaned).to eql("foo" => %w(bar baz))
    end

    it "leaves normal params alone" do
      params = { "foo" => "bar" }

      cleaned = ParamsCleaner.new(params).cleaned

      expect(cleaned).to eql(params)
    end

    it "does not touch other types of hash-params " do
      params = { "foo" => { "from" => "bar", "to" => "baz" } }

      cleaned = ParamsCleaner.new(params).cleaned

      expect(cleaned).to eql(params)
    end

    it "strips leading and trailing whitespace from string parameters" do
      params = { "foo" => "    bar    " }
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to eql("foo" => "bar")
    end

    it "strips leading and trailing whitespace from array-of-stringstring parameters" do
      params = { "foo" => ["    bar    "] }
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to eql("foo" => %w(bar))
    end
  end
end
