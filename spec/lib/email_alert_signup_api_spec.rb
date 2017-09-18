require 'spec_helper'
require 'email_alert_signup_api'

describe EmailAlertSignupAPI do
  let(:email_alert_api) { double(:email_alert_api) }
  let(:attributes) {
    {
      "format" => "test-reports",
      "filter" => %w(first second),
    }
  }
  let(:available_choices) {
    [
      OpenStruct.new(
        "key" => "first",
        "radio_button_name" => "First thing",
        "topic_name" => "first thing",
        "prechecked" => false,
      ),
      OpenStruct.new(
        "key" => "second",
        "radio_button_name" => "Second thing",
        "topic_name" => "second thing",
        "prechecked" => false,
      ),
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
  let(:mock_subscriber_list) { double(:mock_subscriber_list, subscription_url: subscription_url) }
  let(:mock_response) { double(:mock_response, subscriber_list: mock_subscriber_list) }
  subject(:signup_api_wrapper) {
    EmailAlertSignupAPI.new(
      email_alert_api: email_alert_api,
      attributes: attributes,
      available_choices: available_choices,
      subscription_list_title_prefix: subscription_list_title_prefix,
      filter_key: filter_key
    )
  }

  before do
    allow(email_alert_api).to receive(:find_or_create_subscriber_list).and_return(mock_response)
  end

  describe '#signup_url' do
    it 'returns the url email-alert-api gives back' do
      expect(signup_api_wrapper.signup_url).to eql subscription_url
    end

    context 'with multiple choices selected and a title prefix' do
      it 'asks email-alert-api to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "Format with report types: first thing and second thing",
        )
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
        signup_api_wrapper.signup_url

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => ["first"],
          },
          "title" => "Format with report type: first thing",
        )
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
        signup_api_wrapper.signup_url

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "First thing and second thing",
        )
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
        signup_api_wrapper.signup_url

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
          },
          "title" => "Format",
        )
      end
    end
  end
end
