require "spec_helper"

RSpec.describe SignupUrlHiddenParamsPresenter do
  include FixturesHelper

  let(:view_context) { double(:view_context) }
  let(:params) { double(:params) }

  let(:signup_finder) { cma_cases_signup_content_item }

  describe '#url' do
    before(:each) do
      allow(view_context).to receive(:params).and_return(params)
    end

    it "returns empty hash if none passed in" do
      allow(params).to receive(:to_unsafe_hash).and_return({})
      presenter = SignupUrlHiddenParamsPresenter.new(signup_finder, view_context)
      expect(presenter.hidden_params).to eql({})
    end

    it "returns hash with values if they are included in the content_item" do
      signup_finder_content_item = cma_cases_signup_content_item.tap do |content_item|
        content_item['details']['email_filter_facets'] = [
          {
            'facet_name' => 'filter_part_of_taxonomy'
          }
        ]
      end

      allow(params).to receive(:to_unsafe_hash).and_return('filter_part_of_taxonomy' => 'some-taxon')
      presenter = SignupUrlHiddenParamsPresenter.new(signup_finder_content_item, view_context)
      expect(presenter.hidden_params).to eql('filter_part_of_taxonomy' => %w(some-taxon))
    end

    it "returns empty hash if email_filter_facet are includes facet_choices in the content_item" do
      signup_finder_content_item = cma_cases_signup_content_item.tap do |content_item|
        content_item['details']['email_filter_facets'] = [
          {
            'facet_name' => 'filter_part_of_taxonomy',
            'facet_choices' => [
              {
                "key": 'taxon',
                "radio_button_name": 'Filter by some taxon',
                "topic_name": 'Some taxon',
                "prechecked": false
              }
            ]
          }
        ]
      end

      allow(params).to receive(:to_unsafe_hash).and_return('filter_part_of_taxonomy' => 'some-taxon')
      presenter = SignupUrlHiddenParamsPresenter.new(signup_finder_content_item, view_context)
      expect(presenter.hidden_params).to eql({})
    end

    it "translates a facet name into a filter key if it is present" do
      signup_finder_content_item = cma_cases_signup_content_item.tap do |content_item|
        content_item['details']['email_filter_facets'] = [
          {
            'facet_name' => 'some_arbitrary_facet_name',
            'filter_key' => 'a_filter_key_rummager_can_filter_by',
          }
        ]
      end

      allow(params).to receive(:to_unsafe_hash).and_return('some_arbitrary_facet_name' => 'some-taxon')
      presenter = SignupUrlHiddenParamsPresenter.new(signup_finder_content_item, view_context)
      expect(presenter.hidden_params).to eql('a_filter_key_rummager_can_filter_by' => %w(some-taxon))
    end
  end
end
