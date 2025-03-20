require "spec_helper"

describe Filters::NestedFilter do
  subject(:nested_filter) do
    described_class.new(facet, params)
  end

  let(:facet) { double }
  let(:params) { nil }

  describe "#active?" do
    context "when params is nil" do
      it "is false" do
        expect(nested_filter).not_to be_active
      end
    end

    context "when params is empty" do
      let(:params) { {} }

      it "is false" do
        expect(nested_filter).not_to be_active
      end
    end

    context "when params is missing facet keys" do
      let(:params) do
        { "random_key" => "random_value" }
      end

      it "is false" do
        expect(nested_filter).not_to be_active
      end
    end

    context "when params is missing facet values" do
      let(:params) do
        {
          "main_facet_key" => "main_facet",
          "sub_facet_key" => "sub_facet",
        }
      end

      it "is false" do
        expect(nested_filter).not_to be_active
      end
    end

    context "when params contain both main and sub facet keys and corresponding values" do
      let(:params) do
        {
          "main_facet_key" => "main_facet",
          "sub_facet_key" => "sub_facet",
          "main_facet" => "main-facet-allowed-value-1",
          "sub_facet" => "main-facet-allowed-value-1-sub-facet-allowed-value-1",
        }
      end

      it "is true" do
        expect(nested_filter).to be_active
      end
    end
  end

  describe "#query_hash" do
    let(:facet) do
      {
        "key" => "main_facet",
        "sub_facet_key" => "sub_facet",
        "allowed_values" => [
          {
            "label" => "Allowed value 1",
            "value" => "main-facet-allowed-value-1",
            "sub_facets" => [
              {
                "label" => "Sub facet allowed value 1",
                "value" => "main-facet-allowed-value-1-sub-facet-allowed-value-1",
              },
              {
                "label" => "Sub facet allowed value 2",
                "value" => "main-facet-allowed-value-1-sub-facet-allowed-value-2",
              },
            ],
          },
          {
            "label" => "Allowed value 2",
            "value" => "main-facet-allowed-value-2",
          },
        ],
      }
    end

    context "when params includes both main and sub facet keys" do
      let(:params) do
        {
          "main_facet_key" => "main_facet",
          "sub_facet_key" => "sub_facet",
          "main_facet" => "main-facet-allowed-value-1",
          "sub_facet" => "main-facet-allowed-value-1-sub-facet-allowed-value-1",
        }
      end

      it "contains both facet values" do
        expect(nested_filter.query_hash).to eq("main_facet" => %w[main-facet-allowed-value-1], "sub_facet" => %w[main-facet-allowed-value-1-sub-facet-allowed-value-1])
      end
    end

    context "when params only include the main facet key" do
      let(:params) do
        {
          "main_facet_key" => "main_facet",
          "main_facet" => "main-facet-allowed-value-1",
        }
      end

      it "contains main facet values" do
        expect(nested_filter.query_hash).to eq("main_facet" => %w[main-facet-allowed-value-1])
      end
    end

    context "when params only include the sub facet key" do
      let(:params) do
        {
          "sub_facet_key" => "sub_facet",
          "sub_facet" => "main-facet-allowed-value-1-sub-facet-allowed-value-1",
        }
      end

      it "contains sub facet values" do
        expect(nested_filter.query_hash).to eq("sub_facet" => %w[main-facet-allowed-value-1-sub-facet-allowed-value-1])
      end
    end
  end
end
