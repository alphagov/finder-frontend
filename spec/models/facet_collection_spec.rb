require 'spec_helper'
require 'ostruct'

describe FacetCollection do
  let(:facets) {[]}
  subject { FacetCollection.new(facets: facets) }

  describe "enumerability" do
    context "with 3 facets" do
      let(:facets) { [:a_facet, :another_facet, :and_another_facet] }

      specify { subject.should respond_to(:each) }
      specify { subject.count.should == 3 }
    end
  end

  describe "#values" do
    context "with facets with values" do
      let(:facets) { [
          OpenStruct.new(key: "case_type", value: "merger-investigations"),
          OpenStruct.new(key: "decision_type", value: nil)
      ] }

      it "should return a hash with the keys/values of facets with a non-blank value" do
        subject.values.should == {"case_type" => "merger-investigations"}
      end
    end
  end

  describe "#values=" do
    context "with facets with values" do
      let(:facets) { [
          OpenStruct.new(key: "case_type", value: nil),
          OpenStruct.new(key: "decision_type", value: nil)
      ] }

      it "should accept a hash of key/value pairs, and set the facet values for each" do
        subject.values = {
          "case_type" => "merger-investigations",
          decision_type: "catch-22"
        }
        subject.values.should == {
          "case_type" => "merger-investigations",
          "decision_type" => "catch-22"
        }
      end
    end
  end
end
