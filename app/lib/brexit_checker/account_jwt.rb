class BrexitChecker::AccountJwt
  def initialize(criteria_keys:, subscriber_list_slug:, post_register_uri:, post_login_uri:)
    @criteria_keys = criteria_keys
    @subscriber_list_slug = subscriber_list_slug
    @post_register_uri = post_register_uri
    @post_login_uri = post_login_uri
  end

  def encode(key = ecdsa_key, algorithmn = "ES256")
    JWT.encode payload, key, algorithmn
  end

private

  attr_reader :criteria_keys, :subscriber_list_slug, :post_register_uri, :post_login_uri

  def payload
    {
      uid: client_oauth_id,
      key: client_oauth_key_uuid,
      scopes: scopes,
      attributes: attributes,
      post_register_oauth: post_register_uri,
      post_login_oauth: post_login_uri,
    }
  end

  def scopes
    %w[transition_checker]
  end

  def attributes
    {
      transition_checker_state: {
        criteria_keys: criteria_keys,
        timestamp: Time.zone.now.to_i,
        email_topic_slug: subscriber_list_slug,
      },
    }
  end

  def client_oauth_id
    ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_ID")
  end

  def client_oauth_key_uuid
    ENV.fetch("GOVUK_ACCOUNT_JWT_KEY_UUID")
  end

  def ecdsa_key
    OpenSSL::PKey::EC.new(ENV.fetch("GOVUK_ACCOUNT_JWT_KEY_PEM"))
  end
end
