require "spec_helper"

RSpec.describe FacetsIterator do
  subject(:facets_iterator) { described_class.new(facets) }

  let(:visible_facet) { instance_double(Facet, key: "visible", user_visible?: true) }
  let(:another_visible_facet) { instance_double(Facet, key: "another", user_visible?: true) }
  let(:hidden_facet) { instance_double(Facet, key: "hidden", user_visible?: false) }

  let(:facets) { [visible_facet, hidden_facet, another_visible_facet] }

  describe "#user_visible_count" do
    it "returns the count of visible facets" do
      expect(facets_iterator.user_visible_count).to eq(2)
    end
  end

  describe "#each" do
    it "yields each facet as a FacetPresenter" do
      expect { |block| facets_iterator.each(&block) }
        .to yield_successive_args(
          an_object_having_attributes(key: "visible", section_index: 2, section_count: 2),
          an_object_having_attributes(key: "hidden", section_index: nil, section_count: 2),
          an_object_having_attributes(key: "another", section_index: 2, section_count: 2),
        )
    end
  end
end
