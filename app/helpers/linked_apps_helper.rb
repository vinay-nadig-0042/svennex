module LinkedAppsHelper
  def refresh_gitlab_access_token(linked_app)
    refresh_token = linked_app.refresh_token
    _response = HTTParty.post(
      'https://gitlab.com/oauth/token',
      body: {
        client_id: ENV['GITLAB_OAUTH_CLIENT_ID'],
        client_secret: ENV['GITLAB_OAUTH_CLIENT_SECRET'],
        refresh_token: refresh_token,
        grant_type: 'refresh_token',
        redirect_uri: ENV['GITLAB_OAUTH_REDIRECT_URL']
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    # TODO: Else?
    if _response.code == 200
      response = JSON.parse _response.body
      access_token = response["access_token"]
      refresh_token = response["refresh_token"]

      linked_app.update({
        refresh_token: refresh_token,
        access_token: access_token
      })
    end
  end
end