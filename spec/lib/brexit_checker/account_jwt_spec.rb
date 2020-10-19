require "spec_helper"

RSpec.describe BrexitChecker::AccountJwt do
  let(:private_key) { OpenSSL::PKey::EC.new("prime256v1").tap(&:generate_key) }
  let(:public_key) { OpenSSL::PKey::EC.new(private_key).tap { |k| k.private_key = nil } }
  let(:oauth_client_id) { "transition-checker-id" }
  let(:key_uuid) { "38d7dd82-8436-43b5-ae97-e160101cec50" }
  let(:criteria_keys) { %w[hello world] }
  let(:oauth_uri) { "http://www.example.com" }
  let(:subscriber_list_slug) { "test-slug" }

  before do
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = oauth_client_id
    ENV["GOVUK_ACCOUNT_JWT_KEY_UUID"] = key_uuid
    ENV["GOVUK_ACCOUNT_JWT_KEY_PEM"] = private_key.to_pem
  end

  after do
    ENV["GOVUK_ACCOUNT_OAUTH_CLIENT_ID"] = nil
    ENV["GOVUK_ACCOUNT_JWT_KEY_UUID"] = nil
    ENV["GOVUK_ACCOUNT_JWT_KEY_PEM"] = nil
  end

  it "generates a valid JWT" do
    jwt = described_class.new(criteria_keys, oauth_uri, subscriber_list_slug).encode
    payload, = JWT.decode(jwt, public_key, true, { algorithm: "ES256" })
    expect(payload).to_not be_nil
    expect(payload["uid"]).to eq(oauth_client_id)
    expect(payload["key"]).to eq(key_uuid)
    expect(payload["scopes"]).to eq(%w[transition_checker])
    expect(payload["post_login_oauth"]).to eq(oauth_uri)
  end

  it "includes the criteria keys" do
    jwt = described_class.new(criteria_keys, oauth_uri, subscriber_list_slug).encode
    payload, = JWT.decode(jwt, public_key, true, { algorithm: "ES256" })
    expect(payload.dig("attributes", "transition_checker_state", "criteria_keys")).to eq(criteria_keys)
  end

  it "includes the timestamp" do
    jwt = described_class.new(criteria_keys, oauth_uri, subscriber_list_slug).encode
    payload, = JWT.decode(jwt, public_key, true, { algorithm: "ES256" })
    expect(payload.dig("attributes", "transition_checker_state", "timestamp")).to_not be_nil
  end

  it "includes the email topic slug" do
    jwt = described_class.new(criteria_keys, oauth_uri, subscriber_list_slug).encode
    payload, = JWT.decode(jwt, public_key, true, { algorithm: "ES256" })
    expect(payload.dig("attributes", "transition_checker_state", "email_topic_slug")).to_not be_nil
  end
end
