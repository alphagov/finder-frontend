require "spec_helper"

describe RadioFacet do
  let(:facet_data) {
    {
      'type' => "radio",
      'key' => "document_type",
      'name' => "Document type",
      'short_name' => "Documents",
      'preposition' => "of document type",
    }
  }



  describe "#has_value?" do
    context "value is nil" do
      subject { CheckboxFacet.new(facet_data, nil) }

      specify {
        expect(subject.has_value?).to eql(false)
      }
    end

    context "has a value" do
      subject { CheckboxFacet.new(facet_data, "some_value") }

      specify {
        expect(subject.has_value?).to eql(true)
      }
    end
  end
end
