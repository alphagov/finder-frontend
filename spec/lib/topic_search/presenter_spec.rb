require "spec_helper"
require "securerandom"
# require "gds_api/test_helpers/content_store"

describe TopicSearch::Presenter do
  # include ::GdsApi::TestHelpers::ContentStore
  include TaxonomySpecHelper

  let(:content_id_one) { SecureRandom.uuid }
  let(:content_id_two) { SecureRandom.uuid }
  let(:presenter) { described_class.new(q, search_results, topic_taxonomy) }
  let(:q) { nil }
  let(:search_results) { [] }
  let(:topic_taxonomy) { {} }

  let(:expected) do
    [{
      title: "Title",
      href: "/",
      sub_topics: [{
        title: "Subtitle",
        href: "/",
        pages: [{ title: "Renew your driving licence", link: "/renew-driving-licence" }],
      }],
    }]
  end

  context "when no query is provided" do
    context "when results are not returned" do
      it "returns an empty array" do
        # expect(presenter.results).to eq([])
      end
    end

    context "when results are returned" do
      let(:search_results) {
        (1..10).map { FactoryBot.build(:document_hash) }
      }

      it "returns an empty array" do
        topic_taxonomy_has_taxons

        # expect(presenter.results).to eq([])
      end
    end
  end
end
