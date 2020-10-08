require "openid_connect"

class OidcClient
  class OAuthFailure < RuntimeError; end

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

  def auth_uri(redirect_path: nil)
    nonce = SecureRandom.hex(16)
    state = "#{nonce}:#{redirect_path}"

    {
      uri: client.authorization_uri(
        scope: scopes,
        state: state,
        nonce: nonce,
      ),
      state: state,
    }
  end

  def redirect_uri
    host = "http://#{ENV['VIRTUAL_HOST']}" || ENV["GOVUK_WEBSITE_ROOT"]
    host + Rails.application.routes.url_helpers.transition_checker_new_session_callback_path
  end

  def scopes
    %i[transition_checker]
  end

  def callback(code, state)
    client.authorization_code = code
    access_token = client.access_token!
    (nonce, redirect_path) = state.split(":")
    id_token = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, discover.jwks
    id_token.verify! client_id: client_id, issuer: discover.issuer, nonce: nonce
    {
      access_token: access_token,
      sub: id_token.sub,
      redirect_path: redirect_path,
    }
  end

  def get_checker_attribute(access_token:, refresh_token:)
    response = oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :get,
    )

    if response[:result].empty?
      response.merge(result: {})
    else
      response.merge(result: JSON.parse(response[:result])["claim_value"])
    end
  end

private

  def oauth_request(access_token:, refresh_token:, method:, arg: nil)
    access_token_str = access_token
    refresh_token_str = refresh_token

    args = [attribute_uri, arg].compact

    response = Rack::OAuth2::AccessToken::Bearer.new(access_token: access_token_str).public_send(method, *args)

    unless [200, 404].include? response.status
      client.refresh_token = refresh_token
      access_token = client.access_token!

      response = access_token.public_send(method, *args)
      raise OAuthFailure unless [200, 404].include? response.status

      access_token_str = access_token.token_response[:access_token]
      refresh_token_str = access_token.token_response[:refresh_token]
    end

    {
      access_token: access_token_str,
      refresh_token: refresh_token_str,
      result: response.body,
    }
  rescue AttrRequired::AttrMissing, Rack::OAuth2::Client::Error, URI::InvalidURIError
    raise OAuthFailure
  end

  def attribute_uri
    @attribute_uri = URI.parse(userinfo_endpoint).tap do |u|
      u.path = "/v1/attributes/transition_checker_state"
    end
  end

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
