class BrexitChecker::AccountJwt
  def initialize(criteria_keys, oauth_uri)
    @criteria_keys = criteria_keys
    @oauth_uri = oauth_uri
  end

  def encode(key = ecdsa_key, algorithmn = "ES256")
    JWT.encode payload, key, algorithmn
  end

private

  attr_reader :criteria_keys, :oauth_uri

  def payload
    {
      uid: client_oauth_id,
      key: client_oauth_key_uuid,
      scopes: scopes,
      attributes: attributes,
      post_login_oauth: oauth_uri,
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
      },
    }
  end

  def client_oauth_id
    ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_ID")
  end

  def client_oauth_key_uuid
    ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_KEY_UUID")
  end

  def ecdsa_key
    OpenSSL::PKey::EC.new(ENV.fetch("GOVUK_ACCOUNT_OAUTH_CLIENT_KEY"))
  end
end
