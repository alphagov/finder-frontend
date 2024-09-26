require "spec_helper"

describe KeywordFacet do
  subject { described_class.new(query) }

  let(:labels) { subject.sentence_fragment["values"].map { |v| v["label"] } }
  let(:query) { nil }

  it { is_expected.not_to be_user_visible }

  describe "#sentence_fragment" do
    context "keywords without quotes" do
      let(:query) { "Happy Christmas" }

      let(:first_word) { subject.sentence_fragment["values"].first }
      let(:second_word) { subject.sentence_fragment["values"].second }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(first_word["parameter_key"]).to eql("keywords")
        expect(first_word["label"]).to eql("Happy")
        expect(second_word["label"]).to eql("Christmas")

        expect(subject.sentence_fragment["word_connectors"][:words_connector]).to eql("")
      end
    end

    context "keywords with quotes" do
      let(:query) { "\"Merry Christmas\"" }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(labels).to eql(["\"Merry Christmas\""])
      end
    end

    context "keywords with multiple quotes" do
      let(:query) { "\"Merry Christmas\"\" Happy Birthday\" i'm 100 today" }

      specify do
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(labels).to eql(["\"Merry Christmas\"", "\" Happy Birthday\"", "i'm", "100", "today"])
      end
    end

    context "without any keywords" do
      let(:query) { nil }

      specify do
        expect(subject.sentence_fragment).to be_nil
      end
    end
  end

  describe "#query_params" do
    context "value selected" do
      let(:query) { "keyword" }

      specify do
        expect(subject.query_params).to eql("keywords" => %w[keyword])
      end
    end
  end
end
