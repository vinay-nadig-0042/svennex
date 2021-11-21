class CreateRepoWebhookWorker
  include Sidekiq::Worker
  include LinkedAppsHelper

  sidekiq_options retry: 5

  # TODO: Refactor this whole method

  def perform(autobuild_id)
    autobuild = Autobuild.find(autobuild_id)
    webhook_secret = SecureRandom.hex(20)
    autobuild.update(webhook_secret: webhook_secret)

    if autobuild.code_repo_type == 'github'
      linked_app = autobuild.github_linked_app
      access_token = linked_app.access_token
      client = Octokit::Client.new(access_token: access_token)

      resp = client.create_hook(
        autobuild.code_repo_name,
        'web',
        {
          url: "https://#{ENV['DOMAIN_NAME']}/github/webhooks/#{autobuild.id}",
          content_type: 'json',
          secret: webhook_secret
        },
        {
          events: ['push', 'pull_request'],
          active: true
        })
    elsif autobuild.code_repo_type == 'gitlab'
      linked_app = autobuild.gitlab_linked_app
      access_token = linked_app.access_token
      code_repo_name = autobuild.code_repo_name

      # TODO: Should probably use a client
      Gitlab.endpoint = "https://gitlab.com/api/v4"
      Gitlab.private_token = access_token

      begin
        user = Gitlab.user
      rescue Gitlab::Error::Unauthorized => e
        refresh_gitlab_access_token(linked_app)
        access_token = linked_app.access_token
        Gitlab.private_token = access_token
        user = Gitlab.user
      end

      user_id = user["id"]

      # TODO: Rename code_repo_name to full_repo_name
      repo_name = code_repo_name.split("/").last
      projects = Gitlab.get("/users/#{user_id}/projects?search=#{repo_name}")
      project = projects.to_a.find { |p| p["name"] == repo_name }
      response = Gitlab.add_project_hook(
        project.id,
        "https://#{ENV['DOMAIN_NAME']}/gitlab/webhooks/#{autobuild.id}",
        {
          push_events: 1,
          tag_push_events: 1,
          token: webhook_secret
        }
      )
      autobuild.update(webhook_config: response.to_h)
    end
  end
end