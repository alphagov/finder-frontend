# typed: false
require "spec_helper"

RSpec.describe AdvancedSearchQueryBuilder do
  subject(:instance) do
    described_class.new(
      finder_content_item: content_item,
      params: params,
    )
  end
  let(:content_item) do
    {
      'details' =>
        {
          'facets' => [],
          'filter' => {},
          'reject' => {},
          'default_order' => default_order,
          'default_documents_per_page' => nil,
        }
    }
  end
  let(:params) { {} }
  let(:default_order) { nil }
  describe "#base_return_fields" do
    it "includes document_type and organisations" do
      expect(instance.base_return_fields).to include("content_store_document_type")
      expect(instance.base_return_fields).to include("organisations")
    end
  end

  context 'without keywords' do
    it 'should not include a keyword query' do
      expect(instance.call.first).not_to include("q")
    end

    context 'when guidance' do
      let(:params) { { 'group' => 'guidance_and_regulation' } }
      it "should include an order query" do
        expect(instance.call.first).to include("order" => "-popularity")
      end
    end

    context 'when services' do
      let(:params) { { 'group' => 'services' } }
      it "should include an order query" do
        expect(instance.call.first).to include("order" => "-popularity")
      end
    end

    context 'when not guidance or services' do
      let(:params) { {} }
      it "should include an order query" do
        expect(instance.call.first).to include("order" => "-public_timestamp")
      end

      context "with a custom order" do
        let(:default_order) { "custom_field" }

        it "should include a custom order query" do
          expect(instance.call.first).to include("order" => "custom_field")
        end
      end
    end
  end

  context "with keywords" do
    let(:params) {
      {
        "keywords" => "mangoes",
      }
    }

    it "should include a keyword query" do
      expect(instance.call.first).to include("q" => "mangoes")
    end

    it "should not include an order query" do
      expect(instance.call.first).not_to include("order")
    end

    context "longer than the maximum query length" do
      let(:params) {
        {
          "keywords" => "a" * 1024
        }
      }

      it "should include a truncated" do
        expect(instance.call.first).to include("q" => "a" * SearchQueryBuilder::MAX_QUERY_LENGTH)
      end
    end
  end
end
