require 'spec_helper'
require 'email_alert_signup_api'
require 'digest/md5'

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
      OpenStruct.new(
        "key" => "third",
        "radio_button_name" => "A really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process",
        "topic_name" => "a really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process",
        "prechecked" => false,
      ),
    ]
  }
  let(:subscription_list_title_prefix) {
    {
      "singular" => "Format with report type: ",
      "plural" => "Format with report types: ",
      "many" => "Format: ",
    }
  }
  let(:email_filter_name) {
    {
      "singular" => "report type",
      "plural" => "report types",
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
      email_filter_name: email_filter_name,
      filter_key: filter_key
    )
  }

  before do
    allow(email_alert_api).to receive(:find_or_create_subscriber_list).and_return(mock_response)
  end

  describe '#signup_url' do
    it 'returns the url govuk_delivery gives back' do
      expect(signup_api_wrapper.signup_url).to eql subscription_url
    end

    context 'with multiple choices selected and a title prefix' do
      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        md5_hash_of_topics = Digest::MD5.hexdigest("first thing and second thing")

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "Format: 2 report types - " + md5_hash_of_topics,
          "short_name" => "Format: 2 report types",
          "description" => "Format with report types: first thing and second thing",
        )
      end
    end

    context 'with multiple choices selected and a title prefix, over 255 characters long' do
      let(:attributes) {
        {
          "format" => "test-reports",
          "filter" => %w(first second third),
        }
      }

      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        md5_hash_of_topics = Digest::MD5.hexdigest("first thing, second thing, and a really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process")

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second third),
          },
          "title" => "Format: 3 report types - " + md5_hash_of_topics,
          "short_name" => "Format: 3 report types",
          "description" => "Format with report types: first thing, second thing, and a really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process",
        )
      end
    end

    context 'with one choice selected and a title prefix' do
      let(:attributes) {
        {
          "format" => "test-reports",
          "filter" => %w(first),
        }
      }

      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        md5_hash_of_topics = Digest::MD5.hexdigest("first thing")

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first),
          },
          "title" => "Format: 1 report type - " + md5_hash_of_topics,
          "short_name" => "Format: 1 report type",
          "description" => "Format with report type: first thing",
        )
      end
    end

    context 'with one choice selected and a title prefix, over 255 characters' do
      let(:attributes) {
        {
          "format" => "test-reports",
          "filter" => %w(third),
        }
      }

      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        md5_hash_of_topics = Digest::MD5.hexdigest("a really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process")

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(third),
          },
          "title" => "Format: 1 report type - " + md5_hash_of_topics,
          "short_name" => "Format: 1 report type",
          "description" => "Format with report type: a really long third thing that just pushes the short name over the 255 character limit because we want to see what happens when we do that and make sure everything works just fine in that case and that nothing breaks in the process",
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

      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        md5_hash_of_topics = Digest::MD5.hexdigest("first thing and second thing")

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
            "alert_type" => %w(first second),
          },
          "title" => "2 report types - " + md5_hash_of_topics,
          "short_name" => "2 report types",
          "description" => "first thing and second thing",
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

      it 'asks govuk_delivery to find or create the subscriber list' do
        signup_api_wrapper.signup_url

        expect(email_alert_api).to have_received(:find_or_create_subscriber_list).with(
          "tags" => {
            "format" => "test-reports",
          },
          "title" => "Format",
          "short_name" => "Format",
          "description" => "Format"
        )
      end
    end
  end
end
