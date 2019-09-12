require "spec_helper"

describe KeywordFacet do
  let(:query) { "Happy Christmas" }
  let(:query_with_quotes) { "\"Merry Christmas\"" }
  let(:query_with_multiple_quotes) { "\"Merry Christmas\"\" Happy Birthday\" i'm 100 today" }

  describe "#sentence_fragment" do
    context "keywords without quotes" do
      subject { KeywordFacet.new(query) }

      let(:first_word) { subject.sentence_fragment["values"].first }
      let(:second_word) { subject.sentence_fragment["values"].second }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(first_word["parameter_key"]).to eql("keywords")
        expect(first_word["label"]).to eql("Happy")
        expect(second_word["label"]).to eql("Christmas")

        expect(subject.sentence_fragment["word_connectors"][:words_connector]).to eql("")
      }
    end

    context "keywords with quotes" do
      subject { KeywordFacet.new(query_with_quotes) }
      let(:labels) { subject.sentence_fragment["values"].map { |v| v["label"] } }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(labels).to eql(["\"Merry Christmas\""])
      }
    end

    context "keywords with multiple quotes" do
      subject { KeywordFacet.new(query_with_multiple_quotes) }
      let(:labels) { subject.sentence_fragment["values"].map { |v| v["label"] } }

      specify {
        expect(subject.sentence_fragment["preposition"]).to eql("containing")
        expect(labels).to eql(["\"Merry Christmas\"", "\" Happy Birthday\"", "i'm", "100", "today"])
      }
    end

    context "without any keywords" do
      subject { KeywordFacet.new }

      specify {
        expect(subject.sentence_fragment).to be_nil
      }
    end
  end
  describe "#query_params" do
    context "value selected" do
      subject { KeywordFacet.new("keyword") }
      specify {
        expect(subject.query_params).to eql("keywords" => %w[keyword])
      }
    end
  end
end
