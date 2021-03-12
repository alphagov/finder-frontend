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

  def redirect_uri
    host = ENV["VIRTUAL_HOST"] ? "http://#{ENV['VIRTUAL_HOST']}" : ENV["GOVUK_WEBSITE_ROOT"]
    host + Rails.application.routes.url_helpers.transition_checker_new_session_callback_path
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
