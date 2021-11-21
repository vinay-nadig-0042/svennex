class WebhooksController < ApplicationController
  skip_before_action :verify_authenticity_token, :authenticate_user!, only: [:github, :gitlab]
  before_action :verify_webhook_secret, only: [:github, :gitlab]

  def gitlab
    # First time there is a webhook event
    if @autobuild.gitlab_repository.blank?
      @autobuild.update({
        gitlab_repository: GitlabRepository.new({
          name: gitlab_params.dig(:repository, :name),
          git_url: gitlab_params.dig(:repository, :url),
          http_url: gitlab_params.dig(:repository, :git_http_url),
          ssh_url: gitlab_params.dig(:repository, :git_ssh_url)
        })
      })
    end

    CreateAutobuildWorker.perform_async(github_params[:id], gitlab_params[:webhook].to_json)
    # TODO: What content type does gitlab expect here?
    head 200, content_type: "application/json"
  end

  def github
    # TODO: Is this the best way to check if it's ping/pull?
    if github_params.dig(:ref)
      # This is a push/pull_request event
      CreateAutobuildWorker.perform_async(github_params[:id], github_params[:webhook].to_json)
    else
      # This is a ping event
      webhook_config = github_params.dig(:hook)
      @autobuild.update({
        webhook_config: webhook_config,
        github_repository: GithubRepository.new({
          github_id: github_params.dig(:repository, :id),
          name: github_params.dig(:repository, :name),
          full_name: github_params.dig(:repository, :full_name),
          private: github_params.dig(:repository, :private),
          http_url: github_params.dig(:repository, :html_url),
          description: github_params.dig(:repository, :description),
          api_url: github_params.dig(:repository, :url),
          git_url: github_params.dig(:repository, :git_url),
          ssh_url: github_params.dig(:repository, :ssh_url),
          clone_url: github_params.dig(:repository, :clone_url)
        })
      })

      # TODO: What content type does github expect here?
      head 200, content_type: "application/json"
    end
  end

  private

  def verify_webhook_secret
    @autobuild = Autobuild.find(params[:id])
    webhook_secret = @autobuild.webhook_secret

    if @autobuild.code_repo_type == 'github'
      # Is of the format sha=xxxxx
      sha_header = request.headers["X-Hub-Signature-256"]
      github_sha = sha_header.split("=")[1]

      local_sha = OpenSSL::HMAC.hexdigest("SHA256", webhook_secret, request.body.read)

      unless github_sha == local_sha
        head :forbidden
      end
    elsif @autobuild.code_repo_type == 'gitlab'
      gitlab_secret = request.headers["X-Gitlab-Token"]
      unless gitlab_secret == webhook_secret
        head :forbidden
      end
    end
  end

  def github_params
    params.permit(:id, :ref, repository: {}, webhook: {}, hook: {})
  end

  def gitlab_params
    params.permit(:id, :ref, repository: {}, webhook: {})
  end
end