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
    subject(:instance) { described_class.new({ title: "Y", link: "/y" }, finder) }

    context "for EU Exit guidance finder" do
      let(:finder) do
        double(:finder,
               date_metadata_keys: [],
               text_metadata_keys: [],
               slug: "/find-eu-exit-guidance-business")
      end

      it "is false" do
        expect(instance.show_metadata).to be false
      end
    end

    context "for a finder configured to show metadata" do
      let(:finder) do
        double(:finder,
               date_metadata_keys: [:foo],
               text_metadata_keys: [:bar],
               "display_metadata?": true)
      end


      it "is false" do
        allow(instance).to receive(:metadata).and_return([{ key: 'val' }])
        expect(instance.show_metadata).to be true
      end
    end
  end
end
