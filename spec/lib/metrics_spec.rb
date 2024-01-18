require "spec_helper"

describe Metrics do
  describe ".increment_counter" do
    let(:counter) { double(observe: nil) }

    before do
      stub_const("Metrics::COUNTERS", { foo: counter })
    end

    it "observes an increment of 1 for the given counter with the given labels" do
      described_class.increment_counter(:foo, bar: "baz")

      expect(counter).to have_received(:observe).with(1, bar: "baz")
    end

    it "fails gracefully if the counter does not exist" do
      expect { described_class.increment_counter(:bar) }.not_to raise_error
    end

    it "fails gracefully if the operation raises an error" do
      allow(counter).to receive(:observe).and_raise("boom")

      expect { described_class.increment_counter(:foo) }.not_to raise_error
    end
  end

  describe ".observe_duration" do
    let(:histogram) { double(observe: nil) }

    before do
      stub_const("Metrics::HISTOGRAMS", { foo: histogram })
    end

    it "observes the duration of the given block for the given histogram with the given labels" do
      described_class.observe_duration(:foo, bar: "baz") { "result" }

      expect(histogram).to have_received(:observe).with(kind_of(Float), bar: "baz")
    end

    it "returns the result of the given block" do
      expect(described_class.observe_duration(:foo) { "result" }).to eq("result")
    end

    it "fails gracefully if the histogram does not exist" do
      expect(described_class.observe_duration(:bar) { "result" }).to eq("result")
    end

    it "fails gracefully if the operation raises an error" do
      allow(histogram).to receive(:observe).and_raise("boom")

      expect(described_class.observe_duration(:bar) { "result" }).to eq("result")
    end
  end
end
