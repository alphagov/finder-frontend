require 'spec_helper'

describe Facet do
  let(:facet_class) { Facet }
  subject { facet_class.new }

  describe "to_partial_path" do
    context "with a Facet" do
      specify { subject.to_partial_path.should == "facet" }
    end

    context "with a SelectFacet" do
      let(:facet_class) { SelectFacet }
      specify { subject.to_partial_path.should == "select_facet" }
    end
  end
end
