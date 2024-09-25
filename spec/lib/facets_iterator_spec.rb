require "spec_helper"

RSpec.describe FacetsIterator do
  subject(:facets_iterator) { described_class.new(facets) }

  let(:visible_facet) { instance_double(Facet, has_ga4_section?: true) }
  let(:another_visible_facet) { instance_double(Facet, has_ga4_section?: true) }
  let(:hidden_facet) { instance_double(Facet, has_ga4_section?: false) }

  let(:facets) { [visible_facet, hidden_facet, another_visible_facet] }

  describe "#each_with_index_and_count" do
    it "yields each facet with its index in @facets_with_ga4_section and the count of facets with GA4 section" do
      expect { |block| facets_iterator.each_with_index_and_count(&block) }
        .to yield_successive_args(
          [visible_facet, 0, 2],
          [hidden_facet, nil, 2],
          [another_visible_facet, 1, 2],
        )
    end
  end
end
