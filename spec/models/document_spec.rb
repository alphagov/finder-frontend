require "spec_helper"

describe Document do
  describe "initialization" do
    it 'defaults to nil without a public timestamp' do
      rummager_document = {
        title: 'A title',
        link: 'link.com',
        es_score: 0.005
      }
      finder = double(
        'finder', date_metadata_keys: [], text_metadata_keys: [], links: {}
      )
      document = described_class.new(rummager_document, finder, 0)

      expect(document.public_timestamp).to be_nil
    end

    it 'does not break external links' do
      rummager_document = {
        title: 'A title',
        link: 'https://link.com/mature-cheeses'
      }
      finder = double(
        'finder', date_metadata_keys: [], text_metadata_keys: [], links: {}
      )
      document = described_class.new(rummager_document, finder, 0)

      expect(document.path).to eq("https://link.com/mature-cheeses")
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
    subject(:non_mainstream_document) { described_class.new({ title: "Y", link: "/y", content_store_document_type: 'employment_tribunal_decision', organisations: organisations }, finder, 0) }
    subject(:mainstream_document) { described_class.new({ title: "Y", link: "/y", content_store_document_type: 'simple_smart_answer', organisations: organisations }, finder, 0) }

    let(:finder) do
      double(:finder,
             date_metadata_keys: %w[foo],
             text_metadata_keys: %w[organisations],
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
        allow(finder).to receive(:label_for_metadata_key).with('organisations').and_return('org_label')
      end
      it "Remove organisations metadata for mainstream content only" do
        expect(mainstream_document.metadata).to be_empty
        expect(non_mainstream_document.metadata).to match_array(include(name: 'org_label'))
      end
    end
  end

  describe "#metadata" do
    subject { described_class.new(result_hash, finder, 0) }

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
          tag_values: %w[some-value another-value]
        }
      end

      it 'returns the metadata from the result hash' do
        expect(subject.metadata).to include(
          id: :tag_values,
          labels: %w[some-value another-value],
          name: "Tag values",
          type: "text",
          value: "some-value and 1 others"
        )
      end
    end

    context 'metadata as linked content' do
      let(:result_hash) do
        {
          title: 'the title',
          link: '/the/link',
          facet_values: %w[
            afda44ba-bcb9-42de-87de-6207a8912cbc
            daff3e98-ac54-44c1-aadb-9efe276dd74b
            3dfb99d0-3753-483a-842c-2b724474f349
          ]

        }
      end

      before do
        facet1 = Facet.new('key' => :link_values, 'name' => 'Link values')
        facet2 = Facet.new('key' => :other_link_values, 'name' => 'Other link values')
        allow(finder).to receive(:facet_for_content_id).
          with('afda44ba-bcb9-42de-87de-6207a8912cbc').
          and_return facet1
        allow(finder).to receive(:facet_for_content_id).
          with('daff3e98-ac54-44c1-aadb-9efe276dd74b').
          and_return facet1
        allow(finder).to receive(:facet_for_content_id).
          with('3dfb99d0-3753-483a-842c-2b724474f349').
          and_return facet2

        allow(finder).to receive(:value_for_content_id).
          with('afda44ba-bcb9-42de-87de-6207a8912cbc').
          and_return('link-val-1')
        allow(finder).to receive(:value_for_content_id).
          with('daff3e98-ac54-44c1-aadb-9efe276dd74b').
          and_return('link-val-2')
        allow(finder).to receive(:value_for_content_id).
          with('3dfb99d0-3753-483a-842c-2b724474f349').
          and_return('other-value-1')
      end

      it 'returns facet data' do
        expect(subject.linked_facet_data[0]).to eq(
          key: :link_values,
          labels: %w[link-val-1 link-val-2],
          name: 'Link values',
        )
      end

      it 'returns facet data for `Other link values`' do
        expect(subject.linked_facet_data[1]).to eq(
          key: :other_link_values,
          labels: %w[other-value-1],
          name: 'Other link values',
        )
      end
    end
  end

  describe "es_score" do
    let(:finder) do
      double(:finder,
             date_metadata_keys: [:foo],
             text_metadata_keys: [:bar],
             "display_metadata?": true)
    end
    subject(:instance) { described_class.new({ title: "Y", link: "/y", es_score: 0.005 }, finder, 0) }

    it "es_score is 0.005" do
      expect(instance.es_score).to eq 0.005
    end
  end

  describe '#truncated_description' do
    context 'shows truncated description when description is present' do
      let(:finder) do
        double(:finder,
               date_metadata_keys: [],
               text_metadata_keys: [],
               links: {
                 "ordered_related_items" => [{ "base_path" => "/foo" }]
               })
      end

      description = "The government has many departments. These departments are part of the government."
      truncated_description = "The government has many departments."

      subject(:instance_with_description) { described_class.new({ title: "Y", link: "/y", description: description }, finder, 0) }
      subject(:instance_without_description) { described_class.new({ title: "Y", link: "/y" }, finder, 0) }

      it 'should have truncated description' do
        expect(instance_with_description.truncated_description).to eq(truncated_description)
      end

      it 'should not have truncated description' do
        expect(instance_without_description.truncated_description).to eq(nil)
      end
    end
  end
end
