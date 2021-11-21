class LinkedAppsController < ApplicationController
  include LinkedAppsHelper

  def github_apps
    # Refers to state described here
    # https://docs.github.com/en/developers/apps/building-oauth-apps/authorizing-oauth-apps
    @github_state = SecureRandom.hex(20)
    APP_REDIS_POOL.with do |client|
      client.set(@github_state, current_user.id, ex: 86400)
    end
    @github_url = "https://github.com/login/oauth/authorize?client_id=#{ENV['GITHUB_OAUTH_CLIENT_ID']}&scope=repo&state=#{@github_state}"

    @github_apps = current_user.github_linked_apps.paginate(page: params[:page], per_page: 10)
  end

  def gitlab_apps
    @gitlab_state = SecureRandom.hex(20)
    APP_REDIS_POOL.with do |client|
      client.set(@gitlab_state, current_user.id, ex: 86400)
    end

    @gitlab_url = "https://gitlab.com/oauth/authorize?client_id=#{ENV['GITLAB_OAUTH_CLIENT_ID']}&redirect_uri=#{ENV['GITLAB_OAUTH_REDIRECT_URL']}&response_type=code&state=#{@gitlab_state}&scope=read_repository read_user read_api api"
    @gitlab_apps = current_user.gitlab_linked_apps.paginate(page: params[:page], per_page: 10)
  end

  def github_delete
    github_app = current_user.github_linked_apps.find(params[:id])
    if github_app
      github_app.destroy!
      redirect_to linked_github_apps_path
    end
  end

  def gitlab_delete
    gitlab_app = current_user.gitlab_linked_apps.find(params[:id])
    if gitlab_app
      gitlab_app.destroy!
      redirect_to linked_gitlab_apps_path
    end
  end

  def github_repos_for_app
    # TODO: Error handling
    linked_app = current_user.github_linked_apps.find(params[:id])
    access_token = linked_app.access_token

    # TODO: Should a single instance of client be initialized and used everywhere?
    client = Octokit::Client.new(access_token: access_token)
    client.auto_paginate = true

    # Let's not bombard Github API if a client goes rogue
    repo_names = Rails.cache.fetch("#{session.id}/linked_apps/github/#{linked_app.id}/repos", expires_in: 1.minute) do
      repos = client.repos
      repos.select { |r| r[:owner][:login] == linked_app.username }.pluck(:full_name)
    end
    render json: repo_names
  end

  def gitlab_repos_for_app
    # TODO: Error handling
    linked_app = current_user.gitlab_linked_apps.find(params[:id])
    access_token = linked_app.access_token

    # Let's not bombard Gitlab API if a client goes rogue
    project_names = Rails.cache.fetch("#{session.id}/linked_apps/gitlab/#{linked_app.id}/repos", expires_in: 1.minute) do
      # TODO: Should a single instance of client be initialized and used everywhere?
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
      projects = Gitlab.get("/users/#{user.id}/projects").auto_paginate
      projects.map(&:path_with_namespace)
    end
    render json: project_names
  end

  def github_success
    state = params[:state]
    code = params[:code]
    @success = true

    user_id = APP_REDIS_POOL.with do |client|
      client.get(state)
    end

    # If we can find the state in our cache
    if user_id
      # Push getting access token to the background
      AddNewGithubOrgWorker.perform_async(user_id, code)
    else
      @success = false
    end
  end

  def gitlab_success
    state = params[:state]
    code = params[:code]
    @success = true

    user_id = APP_REDIS_POOL.with do |client|
      client.get(state)
    end

    # If we can find the state in our cache
    if user_id
      # Push getting access token to the background
      AddNewGitlabOrgWorker.perform_async(user_id, code)
    else
      @success = false
    end
  end
end