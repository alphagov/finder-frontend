require 'spec_helper'
require 'ostruct'

describe FacetCollection do
  let(:facets) {[]}
  subject { FacetCollection.new(facets: facets) }

  describe ".from_hash" do
    let(:facet_collection_hash) { {
        "facets" => [facet_hash]
    } }
    subject { FacetCollection.from_hash(facet_collection_hash) }

    context "with a hash describing a select facet" do
      let(:facet_hash) { {
        "type" => "select",
        "name" => "Case type"
      } }

      it "should build a SelectFacet with the facet hash" do
        SelectFacet.stub(:from_hash).with(facet_hash).and_return(:a_select_facet)
        subject.first.should == :a_select_facet
      end
    end
  end

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
