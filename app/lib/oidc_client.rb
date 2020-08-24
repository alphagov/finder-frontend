require "openid_connect"

class OidcClient
  attr_reader :client_id,
              :provider_uri

  delegate :authorization_endpoint,
           :token_endpoint,
           :userinfo_endpoint,
           :end_session_endpoint,
           to: :discover

  def initialize(provider_uri, client_id, secret)
    @provider_uri = provider_uri
    @client_id = client_id
    @secret = secret
  end

  def auth_uri
    nonce = SecureRandom.hex(16)
    {
      uri: client.authorization_uri(
        scope: scopes,
        state: nonce,
        nonce: nonce,
      ),
      state: nonce,
    }
  end

  def redirect_uri
    host = "http://#{ENV['VIRTUAL_HOST']}" || ENV["GOVUK_WEBSITE_ROOT"]
    host + Rails.application.routes.url_helpers.transition_checker_new_session_callback_path
  end

  def scopes
    %i[email transition_checker]
  end

  def callback(code, state)
    client.authorization_code = code
    access_token = client.access_token!
    id_token = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, discover.jwks
    id_token.verify! client_id: client_id, issuer: discover.issuer, nonce: state
    access_token.userinfo!
  end

private

  def client
    @client ||= OpenIDConnect::Client.new(
      identifier: client_id,
      secret: @secret,
      redirect_uri: redirect_uri,
      authorization_endpoint: authorization_endpoint,
      token_endpoint: token_endpoint,
      userinfo_endpoint: userinfo_endpoint,
    )
  end

  def discover
    @discover ||= OpenIDConnect::Discovery::Provider::Config.discover! provider_uri
  end
end
