require "spec_helper"
require "support/taxonomy_helper"

describe PageMetadataHelper, type: :helper do
  include TaxonomySpecHelper
  include TopicFinderHelper

  subject do
    page_metadata(content_item)
  end

  let(:organisations) do
    [{ title: "org1", web_url: "http://www.gov.uk/org1" },
     { title: "org2", web_url: "http://www.gov.uk/org2" }]
  end
  let(:content_item) do
    FactoryBot.build(:content_item, links: { organisations: })
  end

  before do
    topic_taxonomy_has_taxons([FactoryBot.build(:level_one_taxon_hash, content_id: "existing_content_id")])
  end

  describe "#page_metadata" do
    it "contains links to organisations" do
      expect(subject[:from]).to contain_exactly('<a href="http://www.gov.uk/org1">org1</a>', '<a href="http://www.gov.uk/org2">org2</a>')
    end

    describe "there are no organisations" do
      let(:organisations) { [] }

      it 'does not contain the "from" key' do
        expect(subject).not_to have_key(:from)
      end
    end
  end
end
