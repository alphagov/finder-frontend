require 'spec_helper'
require 'ostruct'

describe FacetCollection do
  let(:facets) {[]}
  subject { FacetCollection.new(facets) }

  before do
    subject.stub(:filters) { facets }
  end

  describe "enumerability" do
    context "with 3 facets" do
      let(:facets) { [:a_facet, :another_facet, :and_another_facet] }

      specify { subject.should respond_to(:each) }
      specify { subject.count.should == 3 }
    end
  end

  describe "#values=" do
    context "with facets with values" do
      let(:facets) {
        [
          case_type_facet,
          decision_type_facet,
        ]
      }

      let(:case_type_facet) {
        OpenStruct.new(key: "case_type", value: nil)
      }

      let(:decision_type_facet) {
        OpenStruct.new(key: "decision_type", value: nil)
      }

      it "should accept a hash of key/value pairs, and set the facet values for each" do
        subject.values = {
          "case_type" => "merger-investigations",
          decision_type: "catch-22"
        }

        case_type_facet.value.should == "merger-investigations"
        decision_type_facet.value.should == "catch-22"
      end
    end
  end
end
