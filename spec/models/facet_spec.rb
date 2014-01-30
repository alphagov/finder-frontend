require 'spec_helper'

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

  describe ".from_hash" do
    let(:facet_hash) { {
      "name" => "Case type",
      "key" => "case_type",
      "value" => "merger-inquiries"
    } }
    subject { Facet.from_hash(facet_hash) }

    specify { subject.name.should == "Case type" }
    specify { subject.key.should == "case_type" }
    specify { subject.value.should == "merger-inquiries" }
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
end
