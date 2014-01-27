require 'spec_helper'
require 'ostruct'

describe FacetCollection do
  subject { FacetCollection.new(facets_schema: facets_schema, facet_values: facet_values) }
  let(:facets_schema) { [] }
  let(:facet_values) { {} }

  let(:select_schema) { {
    "type" => "select",
    "key" => "case_type"
  } }

  describe "enumerability" do
    let(:facets_schema) { [select_schema, select_schema, select_schema] }

    specify { subject.should respond_to(:each) }
    specify { subject.count.should == 3 }
  end

  describe "#facets" do
    let(:facets_schema) { [select_schema] }

    context do
      it 'should build facet objects of the right type' do
        SelectFacet.should_receive(:new).with(select_schema, anything).and_return(:a_select_facet)

        subject.facets.first.should == :a_select_facet
      end
    end

    context do
      let(:facet_values) { {
        case_type: "merger-investigations"
      }.with_indifferent_access }

      it 'should assign user submitted values' do
        SelectFacet.should_receive(:new).with(select_schema, "merger-investigations").and_return(:a_select_facet_with_value_set)

        subject.facets.first.should == :a_select_facet_with_value_set
      end
    end
  end

  describe "#to_params" do
    context "with facets with values" do
      before do
        subject.facets << OpenStruct.new(key: "case_type", value: "merger-investigations")
        subject.facets << OpenStruct.new(key: "decision_type", value: nil)
      end

      specify { subject.to_params.should == {"case_type" => "merger-investigations"} }
    end
  end
end
