require 'spec_helper'
require_relative './helpers/facets_helper'

RSpec.describe ResultSetPresenter do
  include FacetsHelper

  subject(:presenter) { ResultSetPresenter.new(finder, filter_params, sort_presenter, metadata_presenter_class) }
  let(:metadata_presenter_class) do
    MetadataPresenter
  end
  let(:finder) do
    double(
      FinderPresenter,
      slug: "/a-finder",
      name: 'A finder',
      results: results,
      document_noun: document_noun,
      sort_options: sort_presenter,
      total: '20 cases',
      facets: a_facet_collection,
      keywords: keywords,
      default_documents_per_page: 10,
      values: {},
      sort: [
        {
          "name" => "Most viewed",
          "key" => "-popularity"
        },
        {
          "name" => "Relevance",
          "key" => "-relevance"
        },
        {
          "name" => "Updated (newest)",
          "key" => "-public_timestamp",
          "default" => true
        }
      ],
      default_sort_option: {
        "name" => "Updated (newest)",
        "key" => "-public_timestamp",
      },
      filters: a_facet_collection.filters
    )
  end

  let(:filter_params) { { keywords: 'test' } }

  let(:a_facet_collection) do
    double(
      FacetCollection,
      filters: [a_facet, another_facet, a_date_facet]
    )
  end

  let(:keywords) { '' }
  let(:document_noun) { 'case' }
  let(:total) { 20 }

  let(:results) do
    ResultSet.new(
      (1..total).map { document },
      total,
    )
  end

  let(:document) do
    double(
      Document,
      title: 'Investigation into the distribution of road fuels in parts of Scotland',
      path: 'slug-1',
      metadata: [
        { id: 'case-state', name: 'Case state', value: 'Open', type: 'text', labels: %W(open) },
        { id: 'opened-date', name: 'Opened date', value: '2006-7-14', type: 'date' },
        { id: 'case-type', name: 'Case type', value: 'CA98 and civil cartels', type: 'text', labels: %W(ca98-and-civil-cartels) },
      ],
      summary: 'I am a document',
      is_historic: false,
      government_name: 'The Government!',
      show_metadata: false,
      format: 'transaction',
      es_score: 0.005
    )
  end

  let(:sort_presenter) do
    double(
      SortPresenter,
      has_options?: false,
      selected_option: { "name" => 'Relevance', "key" => '-relevance' },
      to_hash: {
        options: [
          {
            data_track_category: 'dropDownClicked',
            data_track_action: 'clicked',
            data_track_label: "Relevance",
            label: "Relevance",
            value: "relevance",
            disabled: false,
            selected: true,
          }
        ],
        default_value: nil,
        relevance_value: nil,
      },
    )
  end

  before(:each) do
    allow(finder).to receive(:eu_exit_finder?).and_return(false)
  end

  describe "#displayed_total" do
    it 'combines total with document noun' do
      expect(presenter.displayed_total).to eql("#{total} cases")
    end
  end

  describe '#documents' do
    context "has one document" do
      let(:results) do
        ResultSet.new(
          [document],
          total
        )
      end

      it 'creates a new search_result_presenter hash for each result' do
        search_result_objects = presenter.documents
        expect(search_result_objects.count).to eql(1)
        expect(search_result_objects.first).to be_a(Hash)
      end
    end

    context "has 3 documents" do
      let(:results) do
        ResultSet.new(
          [document, document, document],
          total
        )
      end

      it 'creates a new document for each result' do
        search_result_objects = presenter.documents
        expect(search_result_objects.count).to eql(3)
      end
    end

    context 'check top result' do
      subject(:presenter) { ResultSetPresenter.new(finder, filter_params, sort_presenter, metadata_presenter_class, true) }

      before(:each) do
        allow(finder).to receive(:eu_exit_finder?).and_return(true)
        allow(document_with_higher_es_score).to receive(:truncated_description).and_return("Some description about the Department")
      end

      let(:document_with_higher_es_score) do
        double(
          Document,
          title: 'Investigation into the distribution of road fuels in parts of Scotland',
          description: "Some description about the Department",
          path: 'slug-1',
          metadata: [],
          summary: 'Higher score',
          is_historic: false,
          government_name: 'The Government!',
          show_metadata: false,
          format: 'transaction',
          es_score: 1000.0,
          )
      end

      let(:document_with_lower_es_score) do
        double(
          Document,
          title: 'Investigation into the distribution of road fuels in parts of Scotland',
          path: 'slug-2',
          metadata: [],
          summary: 'Lower score',
          is_historic: false,
          government_name: 'The Government!',
          show_metadata: false,
          format: 'transaction',
          es_score: 100.0,
          )
      end

      context 'top result set if best bet' do
        let(:results) do
          ResultSet.new(
            [document_with_higher_es_score, document_with_lower_es_score],
            total
          )
        end

        it 'has top result true' do
          search_result_objects = presenter.documents
          expect(search_result_objects[0][:document][:top_result]).to eql(true)
          expect(search_result_objects[0][:document][:summary]).to eql("Some description about the Department")
        end
      end

      context 'top result not set if no best bet' do
        let(:results) do
          ResultSet.new(
            [document, document],
            total
          )
        end

        it 'has no top result' do
          search_result_objects = presenter.documents
          expect(search_result_objects[0][:document][:top_result]).to_not eql(true)
        end
      end

      context 'top result not set if show top result is false' do
        subject(:presenter) { ResultSetPresenter.new(finder, filter_params, sort_presenter, metadata_presenter_class, false) }

        it 'has no top result' do
          search_result_objects = presenter.documents
          expect(search_result_objects[0][:document][:top_result]).to_not eql(true)
        end
      end
    end
  end

  describe "#documents_by_facets" do
    let(:primary_facet) do
      double(
        OptionSelectFacet,
        key: 'sector_business_area',
        allowed_values: [
          { 'value' => 'aerospace', 'label' => 'Aerospace' },
          { 'value' => 'agriculture', 'label' => 'Agriculture' },
        ],
        value: %W(aerospace agriculture),
        labels: %W(aerospace agriculture),
      )
    end
  end

  describe '#signup_links' do
    context 'has both signup links' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("/finder.atom")
        allow(finder).to receive(:email_alert_signup_url).and_return("/email_signup")
      end

      it 'returns both signup links' do
        expect(presenter.signup_links).to eq(email_signup_link: "/email_signup",
                                             feed_link: "/finder.atom",
                                             hide_heading: true,
                                             small_form: true)
      end
    end

    context 'has just has the atom signup link' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("/finder.atom")
        allow(finder).to receive(:email_alert_signup_url).and_return("")
      end

      it 'returns just the atom link' do
        expect(presenter.signup_links).to eq(feed_link: "/finder.atom", hide_heading: true,
                                             small_form: true)
      end
    end
  end


  describe '#has_email_signup_link?' do
    context 'has one signup link' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("")
        allow(finder).to receive(:email_alert_signup_url).and_return("/email_signup")
      end

      it 'returns true' do
        expect(presenter.has_email_signup_link?).to eq(true)
      end
    end

    context 'has no links' do
      before(:each) do
        allow(finder).to receive(:atom_url).and_return("")
        allow(finder).to receive(:email_alert_signup_url).and_return("")
      end

      it 'returns false' do
        expect(presenter.has_email_signup_link?).to eq(false)
      end
    end
  end
end
