require "spec_helper"
require "support/taxonomy_helper"

RSpec.describe SignupLinksPresenter do
  include GovukContentSchemaExamples
  include TaxonomySpecHelper

  subject(:presenter) { described_class.new(content_item, facets, keywords) }
  let(:keywords) { nil }
  let(:facets) { [] }
  let(:content_item) do
    content_item_hash = {
      content_id: "content_id",
      base_path: "/mosw-reports",
      title: "A finder",
      name: "A finder",
      links: {
        email_alert_signup: Array.wrap(email_signup_hash),
      },
      details: {
        show_summaries: true,
        document_noun: "case",
        sort: [
          {
            "name" => "Most viewed",
            "key" => "-popularity",
          },
          {
            "name" => "Relevance",
            "key" => "-relevance",
          },
          {
            "name" => "Updated (newest)",
            "key" => "-public_timestamp",
            "default" => true,
          },
        ],
      },
    }
    ContentItem.new(content_item_hash.deep_stringify_keys)
  end

  let(:email_signup_hash) do
    {
      base_path: "/email_signup",
    }
  end

  describe "url helpers" do
    let(:hidden_facet_hash) do
      {
        "filter_key": "hidden",
        "key": "topic",
        "type": "hidden",
        "filterable": true,
        "allowed_values": [{ "value" => "hidden_facet_content_id" }],
      }.deep_stringify_keys
    end

    let(:facets) do
      [HiddenFacet.new(hidden_facet_hash, facet_values)]
    end

    describe "#email_signup_link" do
      context "with no values" do
        let(:facet_values) { [] }

        it "returns the finder URL appended with /email-signup" do
          expect(subject.signup_links[0][:email_signup_link]).to eql("/email_signup")
        end
      end

      context "with some values" do
        let(:email_signup_hash) do
          {
            "api_path": "/api/content/mosw-reports/email-signup",
            "base_path": "/mosw-reports/email-signup",
            "content_id": "12dd2b13-93ec-4ca6-a7a4-e2eb5f5d485a",
            "document_type": "finder_email_signup",
            "locale": "en",
            "public_updated_at": "2019-01-24T10:22:17Z",
            "schema_name": "finder_email_signup",
            "title": "MOSW reports",
            "withdrawn": false,
            "links": {},
            "api_url": "https://www.gov.uk/api/content/mosw-reports/email-signup",
            "web_url": "/mosw-reports/email-signup",
          }
        end

        let(:facet_values) do
          %w[hidden_facet_content_id]
        end

        it "returns the finder URL appended with permitted query params" do
          expect(subject.signup_links[0][:email_signup_link]).to eql("/mosw-reports/email-signup?topic%5B%5D=hidden_facet_content_id")
          expect(subject.signup_links[0][:email_signup_link_data_attributes][:ga4_index]).to eql({ index_link: 1, index_total: 4 })
          expect(subject.signup_links[0][:feed_link]).to eql("/mosw-reports.atom?topic%5B%5D=hidden_facet_content_id")
          expect(subject.signup_links[0][:feed_link_data_attributes][:ga4_index]).to eql({ index_link: 2, index_total: 4 })

          expect(subject.signup_links[1][:email_signup_link]).to eql("/mosw-reports/email-signup?topic%5B%5D=hidden_facet_content_id")
          expect(subject.signup_links[1][:email_signup_link_data_attributes][:ga4_index]).to eql({ index_link: 3, index_total: 4 })
          expect(subject.signup_links[1][:feed_link]).to eql("/mosw-reports.atom?topic%5B%5D=hidden_facet_content_id")
          expect(subject.signup_links[1][:feed_link_data_attributes][:ga4_index]).to eql({ index_link: 4, index_total: 4 })
        end
      end
    end

    describe "#signup_links[:feed_link]" do
      context "with no values" do
        let(:facet_values) do
          []
        end
        it "returns the finder URL appended with .atom" do
          expect(subject.signup_links[0][:feed_link]).to eql("/mosw-reports.atom")
        end
      end

      context "with some values" do
        let(:facet_values) do
          %w[hidden_facet_content_id]
        end

        let(:keywords) do
          "micropig"
        end

        it "returns the finder URL appended with permitted query params" do
          expect(subject.signup_links[0][:feed_link]).to eql("/mosw-reports.atom?keywords=micropig&topic%5B%5D=hidden_facet_content_id")
        end
      end

      context "with a licence transaction" do
        let(:facet_values) do
          []
        end

        before do
          allow(content_item).to receive(:is_licence_transaction?).and_return(true)
        end

        it "returns nil" do
          expect(subject.signup_links[0][:feed_link]).to be nil
        end
      end
    end
  end

  describe "only a feed link" do
    let(:content_item) do
      content_item_hash = {
        content_id: "content_id",
        base_path: "/mosw-reports",
        title: "A finder",
        name: "A finder",
        links: {},
        signup_link: false,
        email_alert_signup: false,
        details: {
          show_summaries: true,
          document_noun: "case",
          sort: [
            {
              "name" => "Most viewed",
              "key" => "-popularity",
            },
            {
              "name" => "Relevance",
              "key" => "-relevance",
            },
            {
              "name" => "Updated (newest)",
              "key" => "-public_timestamp",
              "default" => true,
            },
          ],
        },
      }
      ContentItem.new(content_item_hash.deep_stringify_keys)
    end

    let(:email_signup_hash) do
      {}
    end

    it "returns data for the feed link only" do
      expect(subject.signup_links[0][:feed_link]).to eql("/mosw-reports.atom")
      expect(subject.signup_links[0][:feed_link_data_attributes][:ga4_index]).to eql({ index_link: 1, index_total: 2 })
      expect(subject.signup_links[0][:email_signup_link]).to eql(nil)
      expect(subject.signup_links[0][:email_signup_link_data_attributes]).to eql(nil)

      expect(subject.signup_links[1][:feed_link]).to eql("/mosw-reports.atom")
      expect(subject.signup_links[1][:feed_link_data_attributes][:ga4_index]).to eql({ index_link: 2, index_total: 2 })
      expect(subject.signup_links[1][:email_signup_link]).to eql(nil)
      expect(subject.signup_links[1][:email_signup_link_data_attributes]).to eql(nil)
    end
  end

  describe "only an email link" do
    let(:content_item) do
      content_item_hash = {
        content_id: "content_id",
        base_path: "/find-licences",
        title: "A finder",
        name: "A finder",
        links: {
          email_alert_signup: Array.wrap(email_signup_hash),
        },
        details: {
          show_summaries: true,
          document_noun: "case",
          sort: [
            {
              "name" => "Most viewed",
              "key" => "-popularity",
            },
            {
              "name" => "Relevance",
              "key" => "-relevance",
            },
            {
              "name" => "Updated (newest)",
              "key" => "-public_timestamp",
              "default" => true,
            },
          ],
        },
      }
      ContentItem.new(content_item_hash.deep_stringify_keys)
    end

    it "returns data for the email signup link only" do
      expect(subject.signup_links[0][:feed_link]).to eql(nil)
      expect(subject.signup_links[0][:feed_link_data_attributes]).to eql(nil)
      expect(subject.signup_links[0][:email_signup_link]).to eql("/email_signup")
      expect(subject.signup_links[0][:email_signup_link_data_attributes][:ga4_index]).to eql({ index_link: 1, index_total: 2 })

      expect(subject.signup_links[1][:feed_link]).to eql(nil)
      expect(subject.signup_links[1][:feed_link_data_attributes]).to eql(nil)
      expect(subject.signup_links[1][:email_signup_link]).to eql("/email_signup")
      expect(subject.signup_links[1][:email_signup_link_data_attributes][:ga4_index]).to eql({ index_link: 2, index_total: 2 })
    end
  end
end
