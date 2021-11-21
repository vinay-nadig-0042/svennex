class AddNewGithubOrgWorker
  include Sidekiq::Worker
  sidekiq_options retry: 2, dead: false

  def perform(user_id, code)
    user = User.find(user_id)
    _response = HTTParty.post(
      'https://github.com/login/oauth/access_token',
      body: {
        client_id: ENV['GITHUB_OAUTH_CLIENT_ID'],
        client_secret: ENV['GITHUB_OAUTH_CLIENT_SECRET'],
        code: code
      }.to_json,
      headers: { 'Content-Type' => 'application/json' }
    )

    # TODO: Else?
    if _response.code == 200
      response = CGI::parse(_response.body)
      access_token = response["access_token"][0]
      client = Octokit::Client.new(access_token: access_token)

      # TODO: Error handling here
      response = client.user

      username = response[:login]
      url = response[:html_url]
      # TODO: This works for response of type :user. Are there other types?
      type = response[:type]

      existing_github_app = user.github_linked_apps.find_by_username(username)

      if existing_github_app
        existing_github_app.update(status: 'completed')
      else
        existing_github_app = user.github_linked_apps.create!({
          access_token: access_token,
          username: username,
          url: url,
          status: 'completed'
        })
      end

      # PopulateReposForGithubWorker.perform_async(existing_github_app.id)
    end
  end
end