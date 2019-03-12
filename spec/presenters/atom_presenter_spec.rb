require 'spec_helper'

RSpec.describe AtomPresenter do
  subject(:instance) { described_class.new(finder, results) }

  let(:results) { ResultSetPresenter.new(finder, filter_params, view_context) }

  let(:finder) do
    double(
      FinderPresenter,
      slug: "/search/news-and-communications",
      name: 'News and communications',
      results: result_set,
      document_noun: 'case',
      total: 20,
      filters: a_facet_collection.filters,
      facets: a_facet_collection,
      keywords: '',
      atom_url: "/a-finder.atom",
      default_documents_per_page: 10,
      values: {},
      pagination: { 'current_page' => 1, 'total_pages' => 2 },
      sort: {},
    )
  end

  let(:filter_params) { double(:filter_params, keywords: '') }
  let(:view_context) { double(:view_context) }

  let(:a_facet) do
    double(
      SelectFacet,
      key: 'key_1',
      sentence_fragment: {
        'key' => 'key_1',
        'type' => 'text',
        'preposition' => 'About',
        'values' => first_facet_values,
        'word_connectors' => { words_connector: 'and' }
      },
      has_filters?: true,
      value: ['brexit', 'harry-potter']
    )
  end

  let(:first_facet_values) do
    [{ 'label' => 'Brexit' }, { 'label' => 'Harry Potter' }]
  end

  let(:second_facet_values) do
    [{ 'label' => 'Farming' }, { 'label' => 'Chemicals' }]
  end

  let(:a_date_facet) do
    double(
      SelectFacet,
      'key' => 'closed_date',
      sentence_fragment: nil,
      has_filters?: false,
      'word_connectors' => { words_connector: 'or' }
    )
  end

  let(:result_set) do
    ResultSet.new((1..20).map { document }, 20)
  end

  let(:another_facet) do
    double(
      SelectFacet,
      key: 'key_2',
      preposition: 'About',
      sentence_fragment: {
        'key' => 'key_2',
        'type' => 'text',
        'preposition' => 'Related to',
        'values' => second_facet_values,
        'word_connectors' => { words_connector: 'or' }
      },
      has_filters?: true,
      value: %w[farming chemicals],
      'word_connectors' => { words_connector: 'or' }
    )
  end

  let(:a_date_facet) do
    double(SelectFacet, has_filters?: false)
  end

  let(:a_facet_collection) do
    double(
      FacetCollection,
      filters: [a_facet, another_facet, a_date_facet]
    )
  end

  let(:document) do
    double(
      Document,
      updated_at: "2019-02-07T12:21:00Z",
      public_timestamp: "2019-02-01T12:21:00Z",
    )
  end

  describe "#title" do
    it "provides the finder title with filters applied" do
      expect(instance.title).to eql("News and communications about Brexit and Harry Potter related to Farming or Chemicals")
    end

    context "no facets selected" do
      let(:first_facet_values) { [] }
      let(:second_facet_values) { [] }

      it "provides the finder title from the content item when no filters are applied" do
        expect(instance.title).to eql("News and communications")
      end
    end
  end

  describe "#entries" do
    it "provides an array of EntryPresenter documents" do
      expect(instance.entries).to all(be_an(EntryPresenter))
    end
  end

  describe "#updated_at" do
    it "provides the date of the most recent document update" do
      expect(instance.updated_at.to_s).to eql("2019-02-01 12:21:00 UTC")
    end
  end
end
