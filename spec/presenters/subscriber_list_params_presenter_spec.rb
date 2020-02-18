require "spec_helper"

RSpec.describe SubscriberListParamsPresenter do
  include FixturesHelper

  let(:signup_finder) { news_and_communications_signup_content_item }

  describe "#subscriber_list_params" do
    it "returns empty hash if none passed in" do
      params = {}
      presenter = described_class.new(signup_finder, params)
      expect(presenter.subscriber_list_params).to eql({})
    end

    it "returns hash with values if they are included in the content_item" do
      signup_finder_content_item = signup_finder.tap do |content_item|
        content_item["details"]["email_filter_facets"] = [
          {
            "facet_id" => "filter_part_of_taxonomy",
          },
        ]
      end

      params = { "filter_part_of_taxonomy" => "some-taxon" }
      presenter = described_class.new(signup_finder_content_item, params)
      expect(presenter.subscriber_list_params).to eql("filter_part_of_taxonomy" => %w(some-taxon))
    end

    it "returns hash with values if they are dynamic attributes" do
      params = {
        "organisations" => %w[academy-for-social-justice-commissioning accelerated-access-review],
        "people" => %w[sir-philip-jones mark-stanhope],
        "level_one_taxon" => %w[c58fdadd-7743-46d6-9629-90bb3ccc4ef0],
        "related_to_brexit" => "true",
      }

      presenter = described_class.new(signup_finder, params)
      expect(presenter.subscriber_list_params).to eql(
        "organisations" => %w(
          academy-for-social-justice-commissioning
          accelerated-access-review
        ),
        "people" => %w(sir-philip-jones mark-stanhope),
        "all_part_of_taxonomy_tree" => %w(
          c58fdadd-7743-46d6-9629-90bb3ccc4ef0
          d6c2de5d-ef90-45d1-82d4-5f2438369eea
        ),
      )
    end

    it "returns empty hash if email_filter_facet includes facet_choices in the content_item" do
      signup_finder_content_item = signup_finder.tap do |content_item|
        content_item["details"]["email_filter_facets"] = [
          {
            "facet_name" => "filter_part_of_taxonomy",
            "facet_choices" => [
              {
                "key": "taxon",
                "radio_button_name": "Filter by some taxon",
                "topic_name": "Some taxon",
                "prechecked": false,
              },
            ],
          },
        ]
      end

      params = { "filter_part_of_taxonomy" => "some-taxon" }
      presenter = described_class.new(signup_finder_content_item, params)
      expect(presenter.subscriber_list_params).to eql({})
    end

    it "translates a facet id into a filter key if it is present" do
      signup_finder_content_item = signup_finder.tap do |content_item|
        content_item["details"]["email_filter_facets"] = [
          {
            "facet_id" => "some_arbitrary_facet_id",
            "facet_name" => "some_arbitrary_facet_name",
            "filter_key" => "a_filter_key_rummager_can_filter_by",
          },
        ]
      end

      params = { "some_arbitrary_facet_id" => "some-taxon" }
      presenter = described_class.new(signup_finder_content_item, params)
      expect(presenter.subscriber_list_params).to eql("a_filter_key_rummager_can_filter_by" => %w(some-taxon))
    end

    it "translates option_lookup values into a filter key if they are present" do
      signup_finder_content_item = signup_finder.tap do |content_item|
        content_item["details"]["email_filter_facets"] = [
          {
            "facet_id" => "content_store_document_type",
            "facet_name" => "document types",
            "option_lookup" => {
              "policy_papers" => %w(impact_assessment case_study policy_paper),
              "open_consultations" => %w(open_consultation),
              "closed_consultations" => %w(closed_consultation consultation_outcome),
            },
          },
        ]
      end

      params = { "content_store_document_type" => %w(policy_papers open_consultations) }
      presenter = described_class.new(signup_finder_content_item, params)
      expect(presenter.subscriber_list_params).to eql(
        "content_store_document_type" => %w(
          impact_assessment
          case_study
          policy_paper
          open_consultation
        ),
      )
    end
  end
end
