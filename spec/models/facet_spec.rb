require 'spec_helper'

describe Facet do
  let(:facet_class) { Facet }
  let(:schema) { {
    "name" => "Case type",
    "key" => "case_type"
  } }
  let(:value) { "some-value" }
  subject { facet_class.new(schema, value) }

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

  describe "attribute assignment" do
    specify { subject.name.should == "Case type" }
    specify { subject.key.should == "case_type" }

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

  describe "after_initialize hook" do
    class ExampleFacet < Facet
      def after_initialize
        @key = 'overridden'
      end
    end
    let(:facet_class) { ExampleFacet }

    it "should call after_initialize after intialize" do
      subject.key.should == "overridden"
    end
  end
end
