require 'spec_helper'
require 'ostruct'

describe FacetCollection do
  let(:facets) { [] }
  subject { FacetCollection.new(facets) }

  before do
    allow(subject).to receive(:filters).and_return(facets)
  end

  describe "enumerability" do
    context "with 3 facets" do
      let(:facets) { [:a_facet, :another_facet, :and_another_facet] }

      specify { expect(subject).to respond_to(:each) }
      specify { expect(subject.count).to eql(3) }
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

        expect(case_type_facet.value).to eql("merger-investigations")
        expect(decision_type_facet.value).to eql("catch-22")
      end
    end
  end
end
