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

  def tokens!(id_token_nonce: nil)
    access_token = client.access_token!
    response = access_token.token_response

    if id_token_nonce
      id_token = OpenIDConnect::ResponseObject::IdToken.decode access_token.id_token, discover.jwks
      id_token.verify! client_id: client_id, issuer: discover.issuer, nonce: id_token_nonce
    end

    {
      access_token: response[:access_token],
      refresh_token: response[:refresh_token],
      id_token: id_token,
    }.compact
  end

  def auth_uri(redirect_path: nil, state: nil)
    nonce = state || SecureRandom.hex(16)
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
    host = ENV["VIRTUAL_HOST"] ? "http://#{ENV['VIRTUAL_HOST']}" : ENV["GOVUK_WEBSITE_ROOT"]
    host + Rails.application.routes.url_helpers.transition_checker_new_session_callback_path
  end

  def scopes
    %i[transition_checker]
  end

  def callback(code, state)
    nonce, redirect_path = state.split(":")

    client.authorization_code = code

    tokens!(id_token_nonce: nonce).merge(redirect_path: redirect_path)
  end

  def get_checker_attribute(access_token:, refresh_token: nil)
    response = oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :get,
      uri: attribute_uri,
    )

    body = response[:result].body
    if body.empty?
      response.merge(result: {})
    else
      response.merge(result: JSON.parse(body)["claim_value"])
    end
  end

  def set_checker_attribute(value:, access_token:, refresh_token: nil)
    oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :put,
      uri: attribute_uri,
      arg: { value: value.to_json },
    )
  end

  def has_email_subscription(access_token:, refresh_token: nil)
    response = oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :get,
      uri: email_subscription_uri,
    )

    response.merge(result: (200..299).include?(response[:result].status))
  end

  def update_email_subscription(slug:, access_token:, refresh_token: nil)
    oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :post,
      uri: email_subscription_uri,
      arg: { topic_slug: slug },
    )
  end

  def get_ephemeral_state(access_token:, refresh_token: nil)
    response = oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :get,
      uri: ephemeral_state_uri,
    )

    begin
      response.merge(result: JSON.parse(response[:result].body))
    rescue JSON::ParserError
      response.merge(result: {})
    end
  end

  def submit_jwt(jwt:, access_token:, refresh_token: nil)
    response = oauth_request(
      access_token: access_token,
      refresh_token: refresh_token,
      method: :post,
      uri: jwt_uri,
      arg: { jwt: jwt },
    )

    body = response[:result].body
    if body.empty?
      raise OAuthFailure
    else
      response.merge(result: JSON.parse(body)["id"])
    end
  end

private

  OK_STATUSES = [200, 204, 404, 410].freeze

  def oauth_request(access_token:, refresh_token:, method:, uri:, arg: nil)
    access_token_str = access_token
    refresh_token_str = refresh_token

    args = [uri, arg].compact

    response = Rack::OAuth2::AccessToken::Bearer.new(access_token: access_token_str).public_send(method, *args)

    unless OK_STATUSES.include? response.status
      raise OAuthFailure unless refresh_token

      client.refresh_token = refresh_token
      access_token = client.access_token!

      response = access_token.public_send(method, *args)
      raise OAuthFailure unless OK_STATUSES.include? response.status

      access_token_str = access_token.token_response[:access_token]
      refresh_token_str = access_token.token_response[:refresh_token]
    end

    {
      access_token: access_token_str,
      refresh_token: refresh_token_str,
      result: response,
    }
  rescue AttrRequired::AttrMissing, Rack::OAuth2::Client::Error, URI::InvalidURIError
    raise OAuthFailure
  end

  def attribute_uri
    URI.parse(userinfo_endpoint).tap do |u|
      u.path = "/v1/attributes/transition_checker_state"
    end
  end

  def email_subscription_uri
    URI.parse(provider_uri).tap do |u|
      u.path = "/api/v1/transition-checker/email-subscription"
    end
  end

  def ephemeral_state_uri
    URI.parse(provider_uri).tap do |u|
      u.path = "/api/v1/ephemeral-state"
    end
  end

  def jwt_uri
    URI.parse(provider_uri).tap do |u|
      u.path = "/api/v1/jwt"
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
