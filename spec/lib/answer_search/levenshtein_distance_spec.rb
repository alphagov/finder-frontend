require "spec_helper"

describe AnswerSearch::LevenshteinDistance do
  subject(:distance) { described_class.compute(word_one, word_two) }
  let(:word_one) { nil }
  let(:word_two) { nil }

  context "when no words are provided" do
    it "returns 1" do
      expect(distance).to eq 1
    end

    context "when one word is not provided" do
      let(:word_two) { "magic" }
      it "returns 1" do
        expect(distance).to eq 1
      end
    end
  end

  context "when two words are provided" do
    let(:word_pairs) do
      [
        { words: %w(UPPER upper),    distance: 1.0 },
        { words: %w(magic Magic),    distance: 0.2 },
        { words: %w(short longer),   distance: 1.0 },
        { words: %w(cat dog),        distance: 1.0 },
        { words: %w(cat cab),        distance: 0.3333333333333333 },
        { words: %w(abc cba),        distance: 0.6666666666666666 },
        { words: %w(hmrc hrmc),      distance: 0.25 },
        { words: %w(brexit brexit),  distance: 0.0 },
      ]
    end

    it "returns expected distance" do
      distances = word_pairs.map do |pair|
        distance = described_class.compute(*pair[:words])
        pair.merge(distance: distance)
      end

      expect(distances).to eq(word_pairs)
    end
  end
end
