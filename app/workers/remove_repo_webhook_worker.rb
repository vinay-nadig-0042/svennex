class RemoveRepoWebhookWorker
  include Sidekiq::Worker
  include LinkedAppsHelper

  sidekiq_options retry: 3

  def perform(code_repo_type, code_repo_name, webhook_id, linked_app_id)
    if code_repo_type == 'github'
      linked_app = GithubLinkedApp.find(linked_app_id)
      access_token = linked_app.access_token
      client = Octokit::Client.new(access_token: access_token)
      client.remove_hook(
        code_repo_name,
        webhook_id
      )
    elsif code_repo_type == 'gitlab'
      linked_app = GitlabLinkedApp.find(linked_app_id)
      access_token = linked_app.access_token
      Gitlab.endpoint = "https://gitlab.com/api/v4"
      Gitlab.private_token = access_token

      begin
        user = Gitlab.user
      rescue Gitlab::Error::Unauthorized => e
        refresh_gitlab_access_token(linked_app)
        access_token = linked_app.access_token
        Gitlab.private_token = access_token
      end
      projects = Gitlab.get("/users/#{user.id}/projects?search=#{code_repo_name}")
      project = projects.to_a.find { |p| p["name"] == code_repo_name }
      Gitlab.delete_project_hook(
        project.id,
        webhook_id
      )
    end
  end
end