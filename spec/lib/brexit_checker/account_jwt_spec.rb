require "spec_helper"

RSpec.describe BrexitChecker::AccountJwt do
  let(:criteria_keys) { %w[hello world] }
  let(:post_register_uri) { "http://www.example.com/register" }
  let(:post_login_uri) { "http://www.example.com/login" }
  let(:subscriber_list_slug) { "test-slug" }

  let(:jwt) do
    described_class.new(
      criteria_keys: criteria_keys,
      subscriber_list_slug: subscriber_list_slug,
      post_register_uri: post_register_uri,
      post_login_uri: post_login_uri,
    ).encode
  end

  it "generates a valid JWT" do
    payload, = JWT.decode(jwt, nil, false)
    expect(payload).to_not be_nil
    expect(payload["post_register_oauth"]).to eq(post_register_uri)
    expect(payload["post_login_oauth"]).to eq(post_login_uri)
  end

  it "includes the criteria keys" do
    payload, = JWT.decode(jwt, nil, false)
    expect(payload.dig("attributes", "transition_checker_state", "criteria_keys")).to eq(criteria_keys)
  end

  it "includes the timestamp" do
    payload, = JWT.decode(jwt, nil, false)
    expect(payload.dig("attributes", "transition_checker_state", "timestamp")).to_not be_nil
  end

  it "includes the email topic slug" do
    payload, = JWT.decode(jwt, nil, false)
    expect(payload.dig("attributes", "transition_checker_state", "email_topic_slug")).to_not be_nil
  end
end
