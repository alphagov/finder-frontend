require 'rails_helper'

describe Facet do
  let(:facet_class) { Facet }
  subject { facet_class.new }

  describe "#to_partial_path" do
    context "with a Facet" do
      specify { subject.to_partial_path.should == "facet" }
    end

    context "with another kind of facet" do
      class ExampleFacet < Facet; end
      let(:facet_class) { ExampleFacet }
      specify { subject.to_partial_path.should == "example_facet" }
    end
  end

  describe "#value" do
    let(:value) { nil }
    subject { facet_class.new(value: value) }

    context "with a value" do
      let(:value) { "reviews-of-undertakings-and-orders" }
      specify { subject.value.should == "reviews-of-undertakings-and-orders" }
    end

    context "with a nil value" do
      let(:value) { nil }
      specify { subject.value.should be_nil }
    end

    context "with an empty value" do
      let(:value) { "" }
      specify { subject.value.should be_nil }
    end
  end

  describe "#selected_values" do
    it "should return nil" do
      subject.selected_values.should == []
    end
  end
end
