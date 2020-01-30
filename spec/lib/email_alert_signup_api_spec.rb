require "spec_helper"
require "email_alert_signup_api"
require "gds_api/test_helpers/email_alert_api"

describe EmailAlertSignupAPI do
  include GdsApi::TestHelpers::EmailAlertApi
  include RegistrySpecHelper

  subject(:signup_api_wrapper) do
    described_class.new(
      applied_filters: applied_filters,
      default_filters: default_filters,
      facets: facets,
      subscriber_list_title: subscriber_list_title,
    )
  end

  let(:default_filters) { {} }
  let(:applied_filters) { {} }
  let(:facets) { [] }
  let(:subscriber_list_title) { "Subscriber list title" }

  def init_simple_email_alert_api(subscription_url)
    email_alert_api_has_subscriber_list(
      "tags" => {},
      "subscription_url" => subscription_url,
    )
  end

  describe "default_attributes" do
    context "no default_attributes or attributes" do
      describe "#signup_url" do
        let(:subscription_url) { "http://gov.uk/email" }

        it "returns the url email-alert-api gives back" do
          req = init_simple_email_alert_api(subscription_url)

          expect(subject.signup_url).to eql subscription_url
          assert_requested(req)
        end
      end
    end

    context "default attributes provided" do
      describe "#signup_url" do
        let(:subscription_url) { "http://www.example.org/news_and_comms/signup" }
        let(:default_filters) do
          { "content_purpose_supergroup" => "news_and_communications" }
        end

        it "will send email_alert_api the default attributes" do
          req = email_alert_api_has_subscriber_list(
            "tags" => { content_purpose_supergroup: { any: %w(news_and_communications) } },
            "subscription_url" => subscription_url,
          )

          expect(subject.signup_url).to eql subscription_url
          assert_requested(req)
        end
      end
    end
  end

  context "with a single facet finder" do
    let(:default_filters) { { "format" => "test-reports" } }
    let(:applied_filters) do
      { "alert_type" => %w(first second) }
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

    let(:subscription_url) { "http://www.example.org/list-id/signup" }


    describe "#signup_url" do
      it "returns the url email-alert-api gives back" do
        email_alert_api_has_subscriber_list(
          "tags" => {
            format: { any: %w(test-reports) },
            alert_type: { any: %w(first second) },
          },
          "subscription_url" => subscription_url,
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context "with multiple choices selected and a title prefix" do
        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "with one choice selected and a title prefix" do
        let(:applied_filters) do
          {
            format: %w(other-reports),
            alert_type: %w[first],
          }
        end
        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(other-reports test-reports) },
              alert_type: { any: %w[first] },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "without a title prefix" do
        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "no options available" do
        let(:facets) { [] }
        let(:default_filters) { { "format" => "test-reports" } }

        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end
    end
  end

  context "with a multi facet finder" do
    let(:default_filters) { { "format" => "test-reports" } }
    let(:applied_filters) do
      {
        "alert_type" => %w(first second),
        "other_type" => %w(third fourth),
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
    let(:subscription_url) { "http://www.example.org/list-id/signup" }

    before do
      email_alert_api_has_subscriber_list(
        "tags" => {
          format: { any: %w(test-reports) },
          alert_type: { any: %w(first second) },
          other_type: { any: %w(third fourth) },
        },
        "subscription_url" => subscription_url,
      )
    end

    describe "#signup_url" do
      it "returns the url email-alert-api gives back" do
        email_alert_api_has_subscriber_list(
          "tags" => {
            format: { any: %w(test-reports) },
            alert_type: { any: %w(first second) },
          },
          "subscription_url" => subscription_url,
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context "with multiple choices selected and a title prefix" do
        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url,
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

        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w[first] },
              other_type: { any: %w[] },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "without a title prefix" do
        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end

      context "no options available" do
        let(:facets) { [] }
        let(:default_filters) { { "format" => "test-reports" } }

        it "asks email-alert-api to find or create the subscriber list" do
          req = email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "subscription_url" => subscription_url,
          )

          signup_api_wrapper.signup_url
          assert_requested(req)
        end
      end
    end
  end

  describe "business readiness tags" do
    context "with the tags done right" do
      let(:applied_filters) do
        {
          "facet_groups" => %w(52435175-82ed-4a04-adef-74c0199d0f46),
        }
      end
      let(:facets) do
        [
          {
            "facet_id" => "facet_groups",
            "facet_name" => "facet_groups",
            "facet_choices" => [
              {
                "key" => "52435175-82ed-4a04-adef-74c0199d0f46",
                "radio_button_name" => "52435175-82ed-4a04-adef-74c0199d0f46",
                "prechecked" => true,
              },
            ],
          },
        ]
      end
      let(:subscription_url) { "http://gov.uk/email/business-readiness-subscription" }
      let(:signup_content_id) { "not-the-business-readiness-signup-content-id" }


      it "asks email-alert-api to find or create the subscriber list" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            "facet_groups" => { any: %w(52435175-82ed-4a04-adef-74c0199d0f46) },
          },
          "subscription_url" => subscription_url,
        )

        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end
  end

  context "when choices have filter_values" do
    let(:subscription_url) { "http://gov.uk/email/news-and-comms-subscription" }
    let(:applied_filters) do
      { "persons" => %w(people_named_harry people_named_john) }
    end
    let(:facets) do
      [
        {
          "facet_id" => "persons",
          "facet_name" => "persons",
          "facet_choices" => [
            {
              "key" => "people_named_harry",
              "filter_values" => %w(harry_potter harry),
              "topic_name" => "people named Harry",
            },
            {
              "key" => "people_named_john",
              "filter_values" => %w(john),
              "topic_name" => "John",
            },
          ],
        },
      ]
    end

    it "asks email-alert-api to find or create the subscriber list" do
      req = email_alert_api_has_subscriber_list(
        "tags" => {
          persons: { any: %w(harry_potter harry john) },
        },
        "subscription_url" => subscription_url,
      )

      expect(subject.signup_url).to eql subscription_url
      assert_requested(req)
    end
  end

  context "Create link based subscriber lists" do
    let(:subscription_url) { "http://gov.uk/email/news-and-comms-subscription" }
    let(:default_filters) {
      {
        "content_purpose_subgroup": %w[news speeches_and_statements],
      }
    }
    describe "part_of_taxonomy_tree facet" do
      let(:applied_filters) do
        { "all_part_of_taxonomy_tree" => %w(content_id_1 content_id_2) }
      end
      let(:facets) do
        [
          {
            "facet_id" => "all_part_of_taxonomy_tree",
            "facet_name" => "Taxon",
          },
        ]
      end
      it "translates all_part_of_taxonomy_tree to taxon_tree and does not convert values" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            taxon_tree: { all: %w(content_id_1 content_id_2) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end
    describe "content_store_document_type" do
      let(:applied_filters) do
        { "content_store_document_type" => %w(document_type_1 document_type_2) }
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
      it "It does not convert values" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            content_store_document_type: { any: %w(document_type_1 document_type_2) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
      describe "handling default values" do
        let(:default_filters) do
          { "content_purpose_subgroup" => "one_thing" }
        end
        it "it converting scalar values to arrays" do
          req = email_alert_api_has_subscriber_list(
            "links" => {
              content_store_document_type: { any: %w(document_type_1 document_type_2) },
              content_purpose_subgroup: { any: %w[one_thing] },
            },
            "subscription_url" => subscription_url,
          )
          expect(subject.signup_url).to eql subscription_url
          assert_requested(req)
        end
      end
    end
    describe "organisation facet" do
      let(:applied_filters) do
        { "organisations" => %w(death-eaters ministry-of-magic) }
      end
      let(:facets) do
        [
          {
            "facet_id" => "organisations",
            "facet_name" => "Organisations",
          },
        ]
      end
      before :each do
        stub_organisations_registry_request
      end
      it "asks email-alert-api to find or create the subscriber list" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            organisations: { any: %w(content_id_for_death-eaters content_id_for_ministry-of-magic) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end

    describe "world facet" do
      let(:applied_filters) do
        { "world_locations" => %w(location_1 location_2) }
      end
      let(:facets) do
        [
          {
            "facet_id" => "world_locations",
            "facet_name" => "world locations",
          },
        ]
      end
      before :each do
        world_locations = {
          "results": [
            {
              "content_id": "location_id_1",
              "details": {
                "slug": "location_1",
              },
            },
            {
              "content_id": "location_id_2",
              "details": {
                "slug": "location_2",
              },
            },
          ],
        }
        stub_request(:get, "#{Plek.current.find('whitehall-frontend')}/api/world-locations")
          .with(query: hash_including({}))
          .to_return(body: world_locations.to_json)
      end

      it "asks email-alert-api to find or create the subscriber list" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            world_locations: { any: %w(location_id_1 location_id_2) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end
    describe "people facet" do
      let(:applied_filters) do
        { "people" => %w(albus-dumbledore ron-weasley) }
      end
      let(:facets) do
        [
          {
            "facet_id" => "people",
            "facet_name" => "people",
          },
        ]
      end
      before :each do
        stub_people_registry_request
      end

      it "asks email-alert-api to find or create the subscriber list" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            people: { any: %w(content_id_for_albus-dumbledore content_id_for_ron-weasley) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )
        expect(subject.signup_url).to eql subscription_url
        assert_requested(req)
      end
    end

    describe "roles facet" do
      let(:applied_filters) do
        { "roles" => %w(prime-minister) }
      end

      let(:facets) do
        [
          {
            "facet_id" => "roles",
            "facet_name" => "roles",
          },
        ]
      end

      before { stub_roles_registry_request }

      it "asks email-alert-api to find or create the subscriber list" do
        req = email_alert_api_has_subscriber_list(
          "links" => {
            roles: { any: %w(content_id_for_prime-minister) },
            content_purpose_subgroup: { any: %w[news speeches_and_statements] },
          },
          "subscription_url" => subscription_url,
        )

        expect(subject.signup_url).to eql subscription_url

        assert_requested(req)
      end
    end
  end
end
