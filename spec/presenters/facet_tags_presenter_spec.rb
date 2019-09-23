require "spec_helper"
require_relative "./helpers/facets_helper"

describe FacetTagsPresenter do
  include FacetsHelper

  subject(:presenter) { described_class.new(finder_presenter, sort_presenter) }

  let(:finder_presenter) {
    double(
      FinderPresenter,
      filters: [a_facet, another_facet, a_date_facet],
      keywords: keywords,
    )
  }

  let(:keywords) { "" }

  let(:sort_presenter) {
    double(
      SortPresenter,
      selected_option: nil,
    )
  }

  describe "#present" do
    it "returns a hash containing expected keys" do
      expect(presenter.present.keys).to contain_exactly(:applied_filters, :screen_reader_filter_description)
    end
  end

  describe "#selected_filter_descriptions" do
    it "includes prepositions for each facet" do
      applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
      prepositions = applied_filters.flat_map { |filter| filter[:preposition] }.reject { |preposition| preposition == "or" }

      finder_presenter.filters.reject { |filter| filter.sentence_fragment.nil? }.each do |fragment|
        expect(prepositions).to include(fragment.sentence_fragment["preposition"])
      end
    end

    context "when keywords have been searched for" do
      let(:keywords) { "my search term" }

      it "includes the keywords" do
        applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
        text_values = applied_filters.flat_map { |filter| filter[:text] }

        expect(text_values).to include("my", "search", "term")
      end
    end

    context "when XSS attack keywords have been searched for" do
      let(:keywords) { '"><script>alert("hello")</script>' }

      it "escapes keywords appropriately" do
        applied_filters = presenter.selected_filter_descriptions.flat_map { |filter| filter }
        text_values = applied_filters.flat_map { |filter| filter[:text] }

        expect(["script", "alert", "&quot;hello&quot;"].any? { |word| text_values.join(" ").include?(word) })
      end
    end
  end
end
