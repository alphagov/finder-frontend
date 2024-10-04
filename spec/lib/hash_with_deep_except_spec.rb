require "spec_helper"

RSpec.describe "Hash#deep_except" do
  using HashWithDeepExcept

  let(:hash) { { a: 1, b: { c: 2, d: 3 } } }

  context "with top-level keys" do
    it "removes specified keys" do
      expect(hash.deep_except(a: 1)).to eq(b: { c: 2, d: 3 })
    end
  end

  context "with nested keys" do
    it "removes specified nested keys" do
      expect(hash.deep_except(b: { c: 2 })).to eq(a: 1, b: { d: 3 })
    end
  end

  context "when all nested keys are removed" do
    it "removes the entire nested hash" do
      expect(hash.deep_except(b: { c: 2, d: 3 })).to eq(a: 1)
    end
  end

  context "with array values" do
    let(:hash) { { a: [1, 2, 3], b: 4 } }

    it "removes specified array elements" do
      expect(hash.deep_except(a: [2])).to eq(a: [1, 3], b: 4)
    end
  end

  context "when removing single value given as array" do
    let(:hash) { { organisation: "Acme", b: 2 } }

    it "removes the value" do
      expect(hash.deep_except(organisation: %w[Acme])).to eq(b: 2)
    end
  end

  context "with non-matching values" do
    it "does not remove them" do
      expect(hash.deep_except(a: 2, b: { c: 3 })).to eq(a: 1, b: { c: 2, d: 3 })
    end
  end

  context "with empty removal hash" do
    it "returns original hash" do
      expect(hash.deep_except({})).to eq(hash)
    end
  end

  context "with non-existent keys" do
    it "returns original hash" do
      expect(hash.deep_except(x: 1)).to eq(hash)
    end
  end

  context "with deeply nested structures" do
    let(:hash) { { a: { b: { c: { d: 1 } } } } }

    it "removes all nested elements" do
      expect(hash.deep_except(a: { b: { c: { d: 1 } } })).to eq({})
    end
  end

  context "with mixed data types" do
    let(:hash) { { a: 1, b: [1, 2], c: { d: 3 } } }

    it "handles removal correctly" do
      expect(hash.deep_except(a: 1, b: [2], c: { d: 3 })).to eq(b: [1])
    end
  end
end
