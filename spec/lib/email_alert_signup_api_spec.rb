require "spec_helper"
require "email_alert_signup_api"
require "gds_api/test_helpers/email_alert_api"
require "gds_api/test_helpers/worldwide"

describe EmailAlertSignupAPI do
  include GdsApi::TestHelpers::EmailAlertApi
  include GdsApi::TestHelpers::Worldwide
  include RegistrySpecHelper

  subject(:signup_api_wrapper) do
    described_class.new(
      applied_filters: applied_filters,
      default_filters: default_filters,
      facets: facets,
      subscriber_list_title: "title",
    )
  end

  let(:default_filters) { {} }
  let(:applied_filters) { {} }
  let(:facets) { [] }

  describe "#signup_url" do
    context "no default_attributes or attributes" do
      it "returns the url email-alert-api gives back" do
        req = stub_email_alert_api_has_subscriber_list(
          "tags" => {},
          "slug" => "slug",
        )

        subscription_url = "/email/subscriptions/new?topic_id=slug"
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end

    context "default attributes provided" do
      let(:default_filters) do
        { "content_purpose_supergroup" => "news_and_communications" }
      end

      it "calls the API" do
        req = stub_email_alert_api_has_subscriber_list(
          "tags" => { content_purpose_supergroup: { any: %w[news_and_communications] } },
        )

        signup_api_wrapper.signup_url
        assert_requested(req)
      end
    end

    context "with a single facet finder" do
      let(:default_filters) { { "format" => "test-reports" } }
      let(:applied_filters) do
        { "alert_type" => %w[first second] }
      end
      let(:facets) do
        [
          {
            "facet_id" => "alert_type",
            "facet_name" => "alert type",
            "facet_choices" => [
              {
                "key" => "first",
                "radio_button_name" => "First ABC thing",
                "topic_name" => "first ABC thing",
                "prechecked" => false,
              },
              {
                "key" => "second",
                "radio_button_name" => "Second DEF thing",
                "topic_name" => "second DEF thing",
                "prechecked" => false,
              },
            ],
          },
        ]
      end

      context "with multiple choices selected and a title prefix" do
        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
              alert_type: { any: %w[first second] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "with one choice selected and a title prefix" do
        let(:applied_filters) do
          {
            format: %w[other-reports],
            alert_type: %w[first],
          }
        end
        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[other-reports test-reports] },
              alert_type: { any: %w[first] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "without a title prefix" do
        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
              alert_type: { any: %w[first second] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "no options available" do
        let(:facets) { [] }
        let(:default_filters) { { "format" => "test-reports" } }

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end
    end

    context "with a multi facet finder" do
      let(:default_filters) { { "format" => "test-reports" } }
      let(:applied_filters) do
        {
          "alert_type" => %w[first second],
          "other_type" => %w[third fourth],
        }
      end
      let(:facets) do
        [
          {
            "facet_id" => "alert_type",
            "facet_name" => "alert type",
            "facet_choices" => [
              {
                "key" => "first",
                "radio_button_name" => "First ABC thing",
                "topic_name" => "first ABC thing",
                "prechecked" => false,
              },
              {
                "key" => "second",
                "radio_button_name" => "Second DEF thing",
                "topic_name" => "second DEF thing",
                "prechecked" => false,
              },
            ],
          },
          {
            "facet_id" => "other_type",
            "facet_name" => "other type",
            "facet_choices" => [
              {
                "key" => "third",
                "radio_button_name" => "Third GHI thing",
                "topic_name" => "third GHI thing",
                "prechecked" => false,
              },
              {
                "key" => "fourth",
                "radio_button_name" => "Fourth JKL thing",
                "topic_name" => "fourth JKL thing",
                "prechecked" => false,
              },
            ],
          },
        ]
      end

      context "with multiple choices selected and a title prefix" do
        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
              alert_type: { any: %w[first second] },
              other_type: { any: %w[third fourth] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "with one choice selected and a title prefix" do
        let(:default_filters) { { "format" => "test-reports" } }
        let(:applied_filters) do
          {
            "alert_type" => %w[first],
            "other_type" => %w[],
          }
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
              alert_type: { any: %w[first] },
              other_type: { any: %w[] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "without a title prefix" do
        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
              alert_type: { any: %w[first second] },
              other_type: { any: %w[third fourth] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "no options available" do
        let(:facets) { [] }
        let(:default_filters) { { "format" => "test-reports" } }

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w[test-reports] },
            },
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end
    end

    context "when choices have filter_values" do
      let(:applied_filters) do
        { "persons" => %w[people_named_harry people_named_john] }
      end
      let(:facets) do
        [
          {
            "facet_id" => "persons",
            "facet_name" => "persons",
            "facet_choices" => [
              {
                "key" => "people_named_harry",
                "filter_values" => %w[harry_potter harry],
                "topic_name" => "people named Harry",
              },
              {
                "key" => "people_named_john",
                "filter_values" => %w[john],
                "topic_name" => "John",
              },
            ],
          },
        ]
      end

      it "calls the API" do
        req = stub_email_alert_api_has_subscriber_list(
          "tags" => {
            persons: { any: %w[harry_potter harry john] },
          },
        )

        subject.signup_url
        assert_requested(req)
      end
    end

    context "with link-based facets" do
      let(:default_filters) do
        { "content_purpose_subgroup": %w[news speeches_and_statements] }
      end

      context "part_of_taxonomy_tree facet" do
        let(:applied_filters) do
          { "all_part_of_taxonomy_tree" => %w[content_id_1 content_id_2] }
        end

        let(:facets) do
          [
            {
              "facet_id" => "all_part_of_taxonomy_tree",
              "facet_name" => "Taxon",
            },
          ]
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              taxon_tree: { all: %w[content_id_1 content_id_2] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )
          subject.signup_url
          assert_requested(req)
        end
      end

      context "content_store_document_type" do
        let(:applied_filters) do
          { "content_store_document_type" => %w[document_type_1 document_type_2] }
        end

        let(:facets) do
          [
            {
              "facet_id" => "content_store_document_type",
              "facet_name" => "Document Type",
            },
            {
              "facet_id" => "organisations",
              "facet_name" => "Organisations",
            },
          ]
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              content_store_document_type: { any: %w[document_type_1 document_type_2] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )
          subject.signup_url
          assert_requested(req)
        end

        context "handling default values" do
          let(:default_filters) do
            { "content_purpose_subgroup" => "one_thing" }
          end

          it "converts scalar values to arrays" do
            req = stub_email_alert_api_has_subscriber_list(
              "links" => {
                content_store_document_type: { any: %w[document_type_1 document_type_2] },
                content_purpose_subgroup: { any: %w[one_thing] },
              },
            )
            subject.signup_url
            assert_requested(req)
          end
        end
      end

      context "organisation facet" do
        let(:applied_filters) do
          { "organisations" => %w[death-eaters ministry-of-magic] }
        end

        let(:facets) do
          [{ "facet_id" => "organisations", "facet_name" => "Organisations" }]
        end

        before :each do
          stub_organisations_registry_request
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              organisations: { any: %w[content_id_for_death-eaters content_id_for_ministry-of-magic] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )
          subject.signup_url
          assert_requested(req)
        end
      end

      context "world facet" do
        let(:applied_filters) do
          { "world_locations" => %w[location_1 location_2] }
        end

        let(:facets) do
          [{ "facet_id" => "world_locations", "facet_name" => "world locations" }]
        end

        before :each do
          stub_worldwide_api_has_locations(%w[location_1 location_2])
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              world_locations: { any: %w[content_id_for_location_1 content_id_for_location_2] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )
          subject.signup_url
          assert_requested(req)
        end
      end

      context "people facet" do
        let(:applied_filters) do
          { "people" => %w[albus-dumbledore ron-weasley] }
        end

        let(:facets) do
          [{ "facet_id" => "people", "facet_name" => "people" }]
        end

        before :each do
          stub_people_registry_request
        end

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              people: { any: %w[content_id_for_albus-dumbledore content_id_for_ron-weasley] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )
          subject.signup_url
          assert_requested(req)
        end
      end

      context "roles facet" do
        let(:applied_filters) do
          { "roles" => %w[prime-minister] }
        end

        let(:facets) do
          [{ "facet_id" => "roles", "facet_name" => "roles" }]
        end

        before { stub_roles_registry_request }

        it "calls the API" do
          req = stub_email_alert_api_has_subscriber_list(
            "links" => {
              roles: { any: %w[content_id_for_prime-minister] },
              content_purpose_subgroup: { any: %w[news speeches_and_statements] },
            },
          )

          subject.signup_url
          assert_requested(req)
        end
      end
    end
  end
end
