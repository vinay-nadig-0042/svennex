class AddNewGitlabOrgWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2, dead: false

  def perform(user_id, code)
    user = User.find(user_id)
    _response = HTTParty.post(
      'https://gitlab.com/oauth/token',
      body: {
        client_id: ENV['GITLAB_OAUTH_CLIENT_ID'],
        client_secret: ENV['GITLAB_OAUTH_CLIENT_SECRET'],
        code: code,
        grant_type: 'authorization_code',
        redirect_uri: ENV['GITLAB_OAUTH_REDIRECT_URL']
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )


    # TODO: Else?
    if _response.code == 200
      response = JSON.parse _response.body
      access_token = response["access_token"]
      refresh_token = response["refresh_token"]

      Gitlab.endpoint = "https://gitlab.com/api/v4"
      Gitlab.private_token = access_token

      # # TODO: Error handling here
      username = Gitlab.user.username

      url = response[:web_url]

      existing_gitlab_app = user.gitlab_linked_apps.find_by_username(username)

      if existing_gitlab_app
        existing_gitlab_app.update(status: 'completed')
      else
        existing_gitlab_app = user.gitlab_linked_apps.create!({
          access_token: access_token,
          refresh_token: refresh_token,
          username: username,
          url: url,
          status: 'completed'
        })
      end
    end
  end
end