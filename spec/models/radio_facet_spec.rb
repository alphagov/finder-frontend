require "spec_helper"

describe RadioFacet do
  let(:facet_data) do
    {
      "type" => "radio_facet",
      "key" => "type",
      "value" => "selected_value",
      "allowed_values" => [{ "value" => "selected_value" }],
      "filterable" => true,
    }
  end

  describe "#query_params" do
    context "value selected" do
      subject { RadioFacet.new(facet_data, "selected_value") }
      specify do
        expect(subject.query_params).to eql("type" => "selected_value")
      end
    end
  end
end
