require 'spec_helper'

describe HiddenFacet do
  let(:facet_data) {
    {
      'key' => "test_facet",
      'name' => "Test facet",
      'preposition' => "of value"
    }
  }

  let(:facet_class) { HiddenFacet }
  subject { facet_class.new(facet_data) }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { expect(subject.to_partial_path).to eql("hidden_facet") }
    end
  end

  describe "#has_value?" do
    context "value is nil" do
      specify { expect(subject.has_value?).to eql(false) }
    end

    context "value is present" do
      subject { facet_class.new(facet_data, "some value") }
      specify { expect(subject.has_value?).to eql(true) }
    end
  end
end
