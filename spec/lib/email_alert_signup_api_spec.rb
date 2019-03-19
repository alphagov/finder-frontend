require 'spec_helper'
require 'email_alert_signup_api'
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSignupAPI do
  include GdsApi::TestHelpers::EmailAlertApi

  subject(:signup_api_wrapper) do
    described_class.new(
      email_alert_api: Services.email_alert_api,
      attributes: attributes,
      default_attributes: default_attributes,
      available_choices: available_choices,
      subscription_list_title_prefix: subscription_list_title_prefix,
    )
  end

  let(:default_attributes) do
    { filter: {}, reject: {} }
  end

  describe "default_attributes" do
    context "no default_attributes or attributes" do
      describe "#signup_url" do
        let(:subscription_url) { "http://gov.uk/email/news-and-comms-subscription" }
        let(:attributes) { {} }
        let(:available_choices) { {} }
        let(:subscription_list_title_prefix) { "News and communications" }

        it "returns the url email-alert-api gives back" do
          email_alert_api_has_subscriber_list(
            "tags" => {},
            "subscription_url" => subscription_url
          )

          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {},
            "title" => "News and communications",
          ).and_call_original

          expect(subject.signup_url).to eql subscription_url
        end
      end
    end

    context "default attributes provided" do
      describe "#signup_url" do
        let(:subscription_url) { "http://gov.uk/email" }
        let(:attributes) { {} }
        let(:available_choices) { {} }
        let(:subscription_list_title_prefix) { "News and communications" }
        let(:default_attributes) do
          {
            filter: { "content_purpose_supergroup" => 'news_and_communications' },
            reject: { "content_purpose_supergroup" => 'other' }
          }
        end

        it "will send email_alert_api the default attributes" do
          email_alert_api_has_subscriber_list(
            "tags" => {},
            "subscription_url" => subscription_url,
            "content_purpose_supergroup" => "news_and_communications",
          )

          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {},
            "title" => "News and communications",
            "content_purpose_supergroup" => "news_and_communications",
          ).and_call_original

          expect(subject.signup_url).to eql subscription_url
        end
      end
    end
  end

  context "with a single facet finder" do
    let(:attributes) do
      {
        "format" => "test-reports",
        "filter" => {
            "alert_type" => %w(first second)
          },
      }
    end
    let(:available_choices) do
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
    let(:subscription_list_title_prefix) do
      {
        "singular" => "Format with report type: ",
        "plural" => "Format with report types: ",
      }
    end

    let(:subscription_url) { "http://www.example.org/list-id/signup" }

    before do
      email_alert_api_has_subscriber_list(
        "tags" => {
          "format" => { any: "test-reports" },
          "alert_type" => { any: %w(first second) },
        },
        "subscription_url" => subscription_url
      )
    end

    describe '#signup_url' do
      it 'returns the url email-alert-api gives back' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => { any: "test-reports" },
            "alert_type" => { any: %w(first second) },
          },
          "subscription_url" => subscription_url
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context 'with multiple choices selected and a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
            },
            "title" => "Format with report types: first ABC thing and second DEF thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'with one choice selected and a title prefix' do
        let(:attributes) do
          {
            "format" => "test-reports",
            "filter" => {
              "alert_type" => %w[first],
            },
          }
        end
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w[first] },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w[first] },
            },
            "title" => "Format with report type: first ABC thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'without a title prefix' do
        let(:subscription_list_title_prefix) { {} }
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
            },
            "title" => "First ABC thing and second DEF thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'no options available' do
        let(:available_choices) { [] }
        let(:attributes) do
          {
            "format" => "test-reports",
          }
        end
        let(:subscription_list_title_prefix) { "Format" }
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
            },
            "title" => "Format",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end
    end
  end

  context "with a multi facet finder" do
    let(:attributes) do
      {
        "format" => "test-reports",
        "filter" => {
            "alert_type" => %w(first second),
            "other_type" => %w(third fourth)
          },
      }
    end
    let(:available_choices) do
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
    let(:subscription_list_title_prefix) { "Formats " }
    let(:subscription_url) { "http://www.example.org/list-id/signup" }

    before do
      email_alert_api_has_subscriber_list(
        "tags" => {
          "format" => { any: "test-reports" },
          "alert_type" => { any: %w(first second) },
          "other_type" => { any: %w(third fourth) },
        },
        "subscription_url" => subscription_url
      )
    end

    describe '#signup_url' do
      it 'returns the url email-alert-api gives back' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => { any: "test-reports" },
            "alert_type" => { any: %w(first second) },
          },
          "subscription_url" => subscription_url
        )
        expect(signup_api_wrapper.signup_url).to eql subscription_url
      end

      context 'with multiple choices selected and a title prefix' do
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
              "other_type" => { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
              "other_type" => { any: %w(third fourth) },
            },
            "title" => "Formats with alert type of first ABC thing and second DEF thing and other type of third GHI thing and fourth JKL thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'with one choice selected and a title prefix' do
        let(:attributes) do
          {
            "format" => "test-reports",
            "filter" => {
              "alert_type" => %w[first],
              "other_type" => %w[],
            },
          }
        end
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w[first] },
              "other_type" => { any: %w[] },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w[first] },
              "other_type" => { any: %w[] },
            },
            "title" => "Formats with alert type of first ABC thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'without a title prefix' do
        let(:subscription_list_title_prefix) { nil }
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
              "other_type" => { any: %w(third fourth) },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
              "alert_type" => { any: %w(first second) },
              "other_type" => { any: %w(third fourth) },
            },
            "title" => "Alert type of first ABC thing and second DEF thing and other type of third GHI thing and fourth JKL thing",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end

      context 'no options available' do
        let(:available_choices) { [] }
        let(:attributes) do
          {
            "format" => "test-reports",
          }
        end
        let(:subscription_list_title_prefix) { "Format" }
        it 'asks email-alert-api to find or create the subscriber list' do
          email_alert_api_has_subscriber_list(
            "tags" => {
              "format" => { any: "test-reports" },
            },
            "subscription_url" => subscription_url
          )
          expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
            "tags" => {
              "format" => { any: "test-reports" },
            },
            "title" => "Format",
          ).and_call_original

          signup_api_wrapper.signup_url
        end
      end
    end
  end

  describe "business readiness tags" do
    context "with the tags done right" do
      let(:attributes) do
        {
          "filter" => {
              "appear_in_find_eu_exit_guidance_business_finder" => %w(yes),
          },
        }
      end
      let(:subscription_list_title_prefix) { "Business readiness" }
      let(:available_choices) do
        [
          {
            "facet_id" => "appear_in_find_eu_exit_guidance_business_finder",
            "facet_name" => "appear_in_find_eu_exit_guidance_business_finder",
          }
        ]
      end
      let(:subscription_url) { "http://gov.uk/email/business-readiness-subscription" }
      let(:signup_content_id) { "not-the-business-readiness-signup-content-id" }

      before do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "appear_in_find_eu_exit_guidance_business_finder" => { any: %w(yes) },
          },
          "subscription_url" => subscription_url
        )
      end

      it 'asks email-alert-api to find or create the subscriber list' do
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "tags" => {
            "appear_in_find_eu_exit_guidance_business_finder" => { any: %w(yes) },
          },
          "title" => "Business readiness",
        ).and_call_original

        expect(subject.signup_url).to eql subscription_url
      end
    end
  end
end
