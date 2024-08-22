require "spec_helper"

describe ParamsCleaner do
  describe "#cleaned" do
    it "makes an array of a array-like hash" do
      params = ActionController::Parameters.new("foo" => { "0" => "bar", "1" => "baz" })
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to match("foo" => %w[bar baz])
    end

    it "leaves normal params alone" do
      params = ActionController::Parameters.new("foo" => "bar")
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to match("foo" => "bar")
    end

    it "does not touch other types of hash-params " do
      params = ActionController::Parameters.new("foo" => { "from" => "bar", "to" => "baz" })
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to match("foo" => { "from" => "bar", "to" => "baz" })
    end

    it "strips leading and trailing whitespace from string parameters" do
      params = ActionController::Parameters.new("foo" => "    bar    ")
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to match("foo" => "bar")
    end

    it "strips leading and trailing whitespace from array-of-stringstring parameters" do
      params = ActionController::Parameters.new("foo" => ["    bar    "])
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to match("foo" => %w[bar])
    end

    it "removes params with blank values" do
      params = ActionController::Parameters.new("foo" => "  ")
      cleaned = ParamsCleaner.new(params).cleaned
      expect(cleaned).to be_empty
    end
  end

  describe "#fetch" do
    it "returns the param when the default class matches" do
      params = ActionController::Parameters.new("foo" => { "0" => "bar", "1" => "baz" })
      value = ParamsCleaner.new(params).fetch(:foo, [])
      expect(value).to eq(%w[bar baz])
    end

    it "returns the default when the param class differs" do
      params = ActionController::Parameters.new("foo" => { "a" => "bar", "b" => "baz" })
      value = ParamsCleaner.new(params).fetch(:foo, [])
      expect(value).to be_empty
    end
  end
end
