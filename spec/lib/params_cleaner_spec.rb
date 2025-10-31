require "spec_helper"

describe ParamsCleaner do
  describe "#cleaned" do
    it "makes an array of a array-like hash" do
      params = ActionController::Parameters.new("foo" => { "0" => "bar", "1" => "baz" })
      cleaned = described_class.call(params)
      expect(cleaned).to match("foo" => %w[bar baz])
    end

    it "leaves normal params alone" do
      params = ActionController::Parameters.new("foo" => "bar")
      cleaned = described_class.call(params)
      expect(cleaned).to match("foo" => "bar")
    end

    it "does not touch other types of hash-params" do
      params = ActionController::Parameters.new("foo" => { "from" => "bar", "to" => "baz" })
      cleaned = described_class.call(params)
      expect(cleaned).to match("foo" => { "from" => "bar", "to" => "baz" })
    end

    it "strips leading and trailing whitespace from string parameters" do
      params = ActionController::Parameters.new("foo" => "    bar    ")
      cleaned = described_class.call(params)
      expect(cleaned).to match("foo" => "bar")
    end

    it "strips leading and trailing whitespace from array-of-stringstring parameters" do
      params = ActionController::Parameters.new("foo" => ["    bar    "])
      cleaned = described_class.call(params)
      expect(cleaned).to match("foo" => %w[bar])
    end

    it "removes params with blank values" do
      params = ActionController::Parameters.new("foo" => "  ")
      cleaned = described_class.call(params)
      expect(cleaned).to be_empty
    end

    it "returns a hash with indifferent access" do
      params = ActionController::Parameters.new("foo" => "bar")
      cleaned = described_class.call(params)
      expect(cleaned).to be_a(HashWithIndifferentAccess)
    end
  end
end
