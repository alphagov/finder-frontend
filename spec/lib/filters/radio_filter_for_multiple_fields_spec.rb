require "spec_helper"

describe Filters::RadioFilterForMultipleFields do
  class InvalidFilter < Filters::RadioFilterForMultipleFields; end
  class TestFilter < Filters::RadioFilterForMultipleFields
    def filter_hashes
      [
        {
          "value" => "value_1",
          "label" => "label_1",
          "filter" => {
            "field" => "value_1",
          },
        },
        {
          "value" => "default_value",
          "label" => "default_label",
          "filter" => {
            "field" => "default_value",
          },
          "default" => true,
        },
      ]
    end
  end

  let(:facet) { { "key" => "content_store_document_type" } }

  describe "#query_hash" do
    let(:filter) { TestFilter.new(facet, params_value) }
    let(:invalid_filter) { InvalidFilter.new(facet, "params_value") }

    context "no filter hashes are given" do
      it "throws and error" do
        expect { invalid_filter.query_hash }.to raise_error(NotImplementedError)
      end
    end

    context "empty parameter" do
      let(:params_value) { nil }

      it "returns the default query hash" do
        expect(filter.query_hash).to eq("field" => "default_value")
      end
    end

    context "invalid parameter" do
      let(:params_value) { "I'm not valid" }

      it "returns the default query hash" do
        expect(filter.query_hash).to eq("field" => "default_value")
      end
    end

    context "valid parameter" do
      let(:params_value) { "value_1" }

      it "returns valid query hash" do
        expect(filter.query_hash).to eq("field" => "value_1")
      end
    end
  end
end
