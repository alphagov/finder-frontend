require "spec_helper"

describe Document do
  describe "initialization" do
    it 'defaults to nil without a public timestamp' do
      rummager_document = {
        title: 'A title',
        link: 'link.com'
      }
      finder = double(
        'finder', date_metadata_keys: [], text_metadata_keys: []
      )
      document = described_class.new(rummager_document, finder)

      expect(document.public_timestamp).to be_nil
    end
  end

  describe "promoted?" do
    let(:finder) do
      double(:finder,
             date_metadata_keys: [],
             text_metadata_keys: [],
             links: {
               ordered_related_items: [{ title: "Foo", base_path: "/foo" }]
               "ordered_related_items" => [{ "base_path" => "/foo" }]
             })
    end

    it "is true when the finder links contains a match" do
      expect(described_class.new({ title: "Foo", link: "/foo" }, finder).promoted).to be true
    end

    it "is false when the finder links don't include a match" do
      expect(described_class.new({ title: "Bar", link: "/foo" }, finder).promoted).to be false
    end
  end
end
