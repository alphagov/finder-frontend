require 'spec_helper'
require 'email_alert_signup_api'
require 'gds_api/test_helpers/email_alert_api'

describe EmailAlertSignupAPI do
  include GdsApi::TestHelpers::EmailAlertApi

  let(:attributes) {
    {
      "format" => "test-reports",
      "filter" => %w(first second),
    }
  }
  let(:available_choices) {
    [
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
    ]
  }
  let(:subscription_list_title_prefix) {
    {
      "singular" => "Format with report type: ",
      "plural" => "Format with report types: ",
    }
  }
  let(:filter_key) { "alert_type" }
  let(:subscription_url) { "http://www.example.org/list-id/signup" }
  subject(:signup_api_wrapper) {
    described_class.new(
      email_alert_api: Services.email_alert_api,
      attributes: attributes,
      available_choices: available_choices,
      subscription_list_title_prefix: subscription_list_title_prefix,
      filter_key: filter_key
    )
  }

  before do
    email_alert_api_has_subscriber_list(
      "tags" => {
        "format" => "test-reports",
        "alert_type" => %w(first second),
      },
      "subscription_url" => subscription_url
    )
  end

  describe '#signup_url' do
    it 'returns the url email-alert-api gives back' do
      email_alert_api_has_subscriber_list(
        "tags" => {
          "format" => "test-reports",
          "alert_type" => %w(first second),
        },
        "subscription_url" => subscription_url
      )
      expect(signup_api_wrapper.signup_url).to eql subscription_url
    end

    context 'with multiple choices selected and a title prefix' do
      it 'asks email-alert-api to find or create the subscriber list' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "subscription_url" => subscription_url
        )
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "Format with report types: first ABC thing and second DEF thing",
        ).and_call_original

        signup_api_wrapper.signup_url
      end
    end

    context 'with one choice selected and a title prefix' do
      let(:attributes) {
        {
          "format" => "test-reports",
          "filter" => ["first"],
        }
      }
      it 'asks email-alert-api to find or create the subscriber list' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => ["first"],
          },
          "subscription_url" => subscription_url
        )
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => ["first"],
          },
          "title" => "Format with report type: first ABC thing",
        ).and_call_original

        signup_api_wrapper.signup_url
      end
    end

    context 'with no choice selected' do
      let(:attributes) {
        {
          "format" => "test-reports",
          "filter" => [],
        }
      }
      it 'raises an error' do
        expect { signup_api_wrapper.signup_url }.to raise_error(ArgumentError)
      end
    end

    context 'without a title prefix' do
      let(:subscription_list_title_prefix) {
        {}
      }
      it 'asks email-alert-api to find or create the subscriber list' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "subscription_url" => subscription_url
        )
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "First ABC thing and second DEF thing",
        ).and_call_original

        signup_api_wrapper.signup_url
      end
    end

    context 'no options available' do
      let(:available_choices) { [] }
      let(:attributes) {
        {
          "format" => "test-reports",
        }
      }
      let(:filter_key) { nil }
      let(:subscription_list_title_prefix) { "Format" }
      it 'asks email-alert-api to find or create the subscriber list' do
        email_alert_api_has_subscriber_list(
          "tags" => {
            "format" => "test-reports",
          },
          "subscription_url" => subscription_url
        )
        expect(Services.email_alert_api).to receive(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
          },
          "title" => "Format",
        ).and_call_original

        signup_api_wrapper.signup_url
      end
    end
  end
end
