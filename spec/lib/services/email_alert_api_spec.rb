require "spec_helper"
require "gds_api/test_helpers/email_alert_api"

describe Services::EmailAlertApi do
  include GdsApi::TestHelpers::EmailAlertApi

  describe "#find_or_create_subscriber_list_cached" do
    subject(:service) do
      described_class.new.find_or_create_subscriber_list_cached(subscriber_list_options)
    end

    let(:subscriber_list_slug) { "all-releases-filtered-by-corporate-report-a1a2a3a4a5" }

    let(:subscriber_list_options) do
      {
        "title" => "All releases filtered by Corporate report",
        "slug" => subscriber_list_slug,
        "tags" => { content_store_document_type: { any: %w[corporate_report] }, content_purpose_supergroup: { any: %w[transparency] } },
        "url" => "/search/transparency-and-freedom-of-information-releases?content_store_document_type%5B%5D=corporate_report&order=updated-newest",
      }
    end

    context "email-alert-api finds or creates the subscriber list" do
      before do
        @creation_stub = stub_email_alert_api_creates_subscriber_list(subscriber_list_options)
      end

      it "returns a newly created subscriber list" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
      end

      it "caches the subscriber list once created" do
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(subject.dig("subscriber_list", "slug")).to eq(subscriber_list_slug)
        expect(@creation_stub).to have_been_requested.times(1)
      end
    end

    context "email alert api refuses to create the subscriber list" do
      before do
        stub_email_alert_api_refuses_to_create_subscriber_list
      end

      it "bubbles up the 422 error" do
        expect {
          subject
        }.to raise_error(GdsApi::HTTPUnprocessableEntity)
      end
    end
  end
end
