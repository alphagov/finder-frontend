require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

describe Services::EmailAlertApi do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "#find_or_create_subscriber_list_cached" do
    subject(:service) do
      described_class.new.find_or_create_subscriber_list_cached(subscriber_list_options)
    end

    let(:subscriber_list_slug) { "your-get-ready-for-brexit-results-a1a2a3a4a5" }

    let(:subscriber_list_options) do
      {
        "title" => "Your Get ready for Brexit results",
        "slug" => subscriber_list_slug,
        "description" => "You can view a copy of your results on GOV.UK.",
        "tags" => { "brexit_checklist_criteria" => { "any" => %w(does-not-own-business eu-national) } },
        "url" => "/results?c[]=does-not-own-business&c[]=eu-national",
      }
    end

    context "the subscriber list exists in email-alert-api" do
      before do
        @stub = stub_email_alert_api_has_subscriber_list(subscriber_list_options)
      end

      it "returns a subscriber list if one exists" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
      end

      it "returns a cached subscriber list on subsequent requests" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(@stub).to have_been_requested.times(1)
      end
    end

    context "the subscriber list does not exist in email-alert-api" do
      before do
        @not_found_stub = stub_email_alert_api_does_not_have_subscriber_list(subscriber_list_options)
        @creation_stub = stub_email_alert_api_creates_subscriber_list(subscriber_list_options)
      end

      it "returns a newly created subscriber list" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
      end

      it "caches the subscriber list once created" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(@not_found_stub).to have_been_requested.times(1)
        expect(@creation_stub).to have_been_requested.times(1)
      end
    end

    context "email alert api refuses to create the subscriber list" do
      before do
        stub_email_alert_api_does_not_have_subscriber_list(subscriber_list_options)
        email_alert_api_refuses_to_create_subscriber_list
      end

      it "bubbles up the 422 error" do
        expect {
          subject
        }.to raise_error(GdsApi::HTTPUnprocessableEntity)
      end
    end
  end
end
