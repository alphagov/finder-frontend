# typed: false
require 'spec_helper'
require 'email_alert_signup_api'
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSignupAPI do
  include GdsApi::TestHelpers::EmailAlertApi

  subject(:signup_api_wrapper) do
    described_class.new(
      applied_filters: applied_filters,
      default_filters: default_filters,
      facets: facets,
      subscriber_list_title: subscriber_list_title,
      finder_format: finder_format,
      default_frequency: default_frequency,
    )
  end

  let(:default_filters) { {} }
  let(:applied_filters) { {} }
  let(:facets) { [] }
  let(:subscriber_list_title) { "Subscriber list title" }
  let(:finder_format) {}
  let(:default_frequency) { nil }

  def init_simple_email_alert_api(subscription_url)
    email_alert_api_has_subscriber_list(
      "tags" => {},
      "subscription_url" => subscription_url
    )

    expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
      "tags" => {},
      "title" => subscriber_list_title,
    ).and_call_original
  end

  describe "default_attributes" do
    context "no default_attributes or attributes" do
      describe "#signup_url" do
        let(:subscription_url) { "http://gov.uk/email" }

        it "returns the url email-alert-api gives back" do
          init_simple_email_alert_api(subscription_url)

          expect(subject.signup_url).to eql subscription_url
        end
      end
    end

    context "default attributes provided" do
      describe "#signup_url" do
        let(:subscription_url) { "http://www.example.org/news_and_comms/signup" }
        let(:default_filters) do
          { "content_purpose_supergroup" => 'news_and_communications' }
        end

        it "will send email_alert_api the default attributes" do
          email_alert_api_has_subscriber_list(
            "tags" => { content_purpose_supergroup: { any: %w(news_and_communications) } },
            "subscription_url" => subscription_url,
          )

          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => { content_purpose_supergroup: { any: %w(news_and_communications) } },
            "title" => subscriber_list_title,
          ).and_call_original

          expect(subject.signup_url).to eql subscription_url
        end
      end
    end
  end

  context "when a default_frequency is provided" do
    let(:default_frequency) { "daily" }

    it "returns the url email-alert-api gives back, and appends the default_frequency param" do
      subscription_url = "http://gov.uk/email/some-subscription"
      init_simple_email_alert_api(subscription_url)
      expect(subject.signup_url).to eql "http://gov.uk/email/some-subscription?default_frequency=daily"
    end

    it "appends the default_frequency param with an ampersand if other URL parameters exist" do
      subscription_url = "http://gov.uk/email/some-subscription?foo=bar"
      init_simple_email_alert_api(subscription_url)
      url_params = Rack::Utils.parse_query(URI.parse(subject.signup_url).query)
      expect(url_params).to eq("foo" => "bar", "default_frequency" => "daily")
    end
  end

  context "with a single facet finder" do
    let(:finder_format) { "test-reports" }
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
              "prechecked" => false
            },
            {
              "key" => "second",
              "radio_button_name" => "Second DEF thing",
              "topic_name" => "second DEF thing",
              "prechecked" => false,
            }
          ]
        },
      ]
    end

    let(:subscription_url) { "http://www.example.org/list-id/signup" }

    before do
      email_alert_api_has_subscriber_list(
        "tags" => {
          format: { any: %w(test-reports) },
          alert_type: { any: %w(first second) },
        },
        "subscription_url" => subscription_url
      )
    end

    describe '#signup_url' do
      it 'returns the url email-alert-api gives back' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            format: { any: %w(test-reports) },
            alert_type: { any: %w(first second) },
          },
          "subscription_url" => subscription_url
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context 'with multiple choices selected and a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'with one choice selected and a title prefix' do
        let(:applied_filters) do
          {
            format: { any: %w(test-reports) },
            alert_type: %w[first],
          }
        end
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w[first] },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w[first] },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'without a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'no options available' do
        let(:facets) { [] }
        let(:finder_format) { "test-reports" }

        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end
    end
  end

  context "with a multi facet finder" do
    let(:finder_format) { "test-reports" }
    let(:applied_filters) do
      {
        "alert_type" => %w(first second),
        "other_type" => %w(third fourth)
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
              "prechecked" => false
            },
            {
              "key" => "second",
              "radio_button_name" => "Second DEF thing",
              "topic_name" => "second DEF thing",
              "prechecked" => false,
            }
          ]
        },
        {
          "facet_id" => "other_type",
          "facet_name" => "other type",
          "facet_choices" => [
            {
              "key" => "third",
              "radio_button_name" => "Third GHI thing",
              "topic_name" => "third GHI thing",
              "prechecked" => false
            },
            {
              "key" => "fourth",
              "radio_button_name" => "Fourth JKL thing",
              "topic_name" => "fourth JKL thing",
              "prechecked" => false,
            }
          ]
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
        "subscription_url" => subscription_url
      )
    end

    describe '#signup_url' do
      it 'returns the url email-alert-api gives back' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            format: { any: %w(test-reports) },
            alert_type: { any: %w(first second) },
          },
          "subscription_url" => subscription_url
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context 'with multiple choices selected and a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'with one choice selected and a title prefix' do
        let(:finder_format) { "test-reports" }
        let(:applied_filters) do
          {
            "alert_type" => %w[first],
            "other_type" => %w[],
          }
        end

        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w[first] },
              other_type: { any: %w[] },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w[first] },
              other_type: { any: %w[] },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'without a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
              alert_type: { any: %w(first second) },
              other_type: { any: %w(third fourth) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'no options available' do
        let(:facets) { [] }
        let(:finder_format) { "test-reports" }

        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              format: { any: %w(test-reports) },
            },
            "title" => subscriber_list_title,
          ).and_call_original

          signup_api_wrapper.signup_url
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
                "prechecked" => true
              },
            ]
          }
        ]
      end
      let(:subscription_url) { "http://gov.uk/email/business-readiness-subscription" }
      let(:signup_content_id) { "not-the-business-readiness-signup-content-id" }

      before do
        email_alert_api_has_subscriber_list(
          "links" => {
            "facet_groups" => { any: %w(52435175-82ed-4a04-adef-74c0199d0f46) },
          },
          "subscription_url" => subscription_url
        )
      end

      it 'asks email-alert-api to find or create the subscriber list' do
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "links" => {
            "facet_groups" => { any: %w(52435175-82ed-4a04-adef-74c0199d0f46) },
          },
          "title" => subscriber_list_title,
        ).and_call_original

        expect(subject.signup_url).to eql subscription_url
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
            }
          ]
        }
      ]
    end

    before do
      email_alert_api_has_subscriber_list(
        "tags" => {
          persons: { any: %w(harry_potter harry john) },
        },
        "subscription_url" => subscription_url
      )
    end

    it 'asks email-alert-api to find or create the subscriber list' do
      expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
        "tags" => {
          persons: { any: %w(harry_potter harry john) },
        },
        "title" => subscriber_list_title,
      ).and_call_original

      expect(subject.signup_url).to eql subscription_url
    end
  end
end
