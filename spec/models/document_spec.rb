require "spec_helper"

describe Document do
  describe "initialization" do
    it 'defaults to nil without a public timestamp' do
      rummager_document = {
        title: 'A title',
        link: 'link.com'
      }
      finder = double(
        'finder', date_metadata_keys: [], text_metadata_keys: [], links: {}
      )
      document = described_class.new(rummager_document, finder)

      expect(document.public_timestamp).to be_nil
    end
  end

  describe "#promoted" do
    let(:finder) do
      double(:finder,
             date_metadata_keys: [],
             text_metadata_keys: [],
             links: {
               "ordered_related_items" => [{ "base_path" => "/foo" }]
             })
    end

    it "is true when the finder links contains a match" do
      expect(described_class.new({ title: "Foo", link: "/foo" }, finder).promoted).to be true
    end

    it "is false when the finder links don't include a match" do
      expect(described_class.new({ title: "Bar", link: "/bar" }, finder).promoted).to be false
    end

    describe "promoted_summary" do
      context "when the document is promoted" do
        subject(:promoted_document) {
          described_class.new({ title: "Foo", link: "/foo", description: "foo" }, finder)
        }

        it "returns the truncated description" do
          expect(promoted_document.promoted_summary).to eq("foo")
        end
      end

      context "when the document isn't promoted" do
        subject(:document) {
          described_class.new({ title: "Bar", link: "/bar", description: "bar" }, finder)
        }

        it "returns nil" do
          expect(document.promoted_summary).to be nil
        end
      end

      context "with no description" do
        subject(:document) {
          described_class.new({ title: "Foo", link: "/foo" }, finder)
        }

        it "returns nil" do
          expect(document.promoted_summary).to be nil
        end
      end
    end
  end

  describe "show_metadata" do
    let(:organisations) {
      [
          {
              'title' => 'org',
              'name' => 'org'
          }
      ]
    }
    subject(:non_mainstream_document) { described_class.new({ title: "Y", link: "/y", content_store_document_type: 'employment_tribunal_decision', organisations: organisations }, finder) }
    subject(:mainstream_document) { described_class.new({ title: "Y", link: "/y", content_store_document_type: 'simple_smart_answer', organisations: organisations }, finder) }

    let(:finder) do
      double(:finder,
             date_metadata_keys: [:foo],
             text_metadata_keys: [:organisations],
             "display_metadata?": true,
             display_key_for_metadata_key: 'title')
    end

    context "for EU Exit guidance finder" do
      before :each do
        allow(finder).to receive(:slug).and_return "/find-eu-exit-guidance-business"
      end

      it "is false" do
        expect(mainstream_document.show_metadata).to be false
      end
    end

    context "for a finder configured to show metadata" do
      it "is false" do
        allow(mainstream_document).to receive(:metadata).and_return([{ key: 'val' }])
        expect(mainstream_document.show_metadata).to be true
      end
    end

    context "There is an organisations metadata key" do
      before :each do
        allow(finder).to receive(:label_for_metadata_key).with(:organisations).and_return('org_label')
      end
      it "Remove organisations metadata for mainstream content only" do
        expect(mainstream_document.metadata).to be_empty
        expect(non_mainstream_document.metadata).to match_array(include(name: 'org_label'))
      end
    end
  end

  describe "#metadata" do
    subject { described_class.new(result_hash, finder) }

    let(:finder) do
      double(:finder,
        date_metadata_keys: [],
        label_for_metadata_key: 'Tag values',
        text_metadata_keys: [:tag_values],
        "display_metadata?": true)
    end

    context 'metadata in the result hash' do
      let(:result_hash) do
        {
          title: 'the title',
          link: '/the/link',
          tag_values: ['some-value', 'another-value']
        }
      end

      it 'returns the metadata from the result hash' do
        expect(subject.metadata).to include(
          id: :tag_values,
          labels: ["some-value", "another-value"],
          name: "Tag values",
          type: "text",
          value: "some-value and 1 others"
        )
      end
    end
  end
end
