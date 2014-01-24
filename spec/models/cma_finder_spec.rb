require 'spec_helper'

describe CMAFinder do
  subject { CMAFinder.new }

  specify { subject.slug.should == "cma-cases" }
  specify { subject.name.should == "Competition and Markets Authority cases" }

  describe "facets" do
    describe "inquiry type" do
      let(:inquiry_type_facet) {
        subject.facets.find { |facet|
          facet.name == "Inquiry type"
        }
      }

      specify { inquiry_type_facet.should be_a(SelectFacet) }
      specify { inquiry_type_facet.name.should == 'Inquiry type' }
      specify { inquiry_type_facet.key.should == 'inquiry_type' }
      specify {
        inquiry_type_facet.options.should == [
          ['Airport price control reviews',            'airport-price-control-reviews'],
          ['Market investigations',                    'market-investigations'],
          ['Remittals',                                'remittals'],
          ['Telecommunications price control appeals', 'telecommunications-price-control-appeals'],
          ['Energy code modification appeals',         'energy-code-modification-appeals'],
          ['Merger inquiries',                         'merger-inquiries'],
          ['Reviews of undertakings and orders',       'reviews-of-undertakings-and-orders'],
          ['Water price determinations',               'water-price-determinations']
        ]
      }
    end
  end
end
