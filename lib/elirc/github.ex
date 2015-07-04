defmodule OAuth2.GitHub do
  use OAuth2.Strategy

  # Public API
  def new do
    OAuth2.new([
      strategy: __MODULE__,
      client_id: System.get_env("GITHUB_CLIENT_ID"),
      client_secret: System.get_env("GITHUB_CLIENT_SECRET"),
      redirect_uri: System.get_env("GITHUB_REDIRECT_URI"),
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token"
    ])
  end

  def authorize_url!(params \\ []) do
    new()
    |> put_param(:scope, "public_repo")
    |> OAuth2.Client.authorize_url!(params)
  end

  def get_token!(params \\ [], headers \\ []) do
    new()
      |> OAuth2.Client.get_token!(params, headers)
  end

  # Strategy Callbacks

  def authorize_url(client, params) do
    OAuth2.Strategy.AuthCode.authorize_url(client, params)
  end

  def get_token(client, params, headers) do
    client
    |> OAuth2.Strategy.AuthCode.get_token(params, headers)
  end
end