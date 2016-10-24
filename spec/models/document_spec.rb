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
end
