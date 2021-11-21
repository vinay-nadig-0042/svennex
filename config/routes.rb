require 'sidekiq/web'
require "sidekiq/cron/web"

Rails.application.routes.draw do
  resources :docker_hub_registries
  resources :autobuilds
  devise_for :users, controllers: {
    registrations: 'user/registrations'
  }

  get '/oauth/github/apps', to: 'linked_apps#github_apps', as: 'linked_github_apps'
  get '/oauth/gitlab/apps', to: 'linked_apps#gitlab_apps', as: 'linked_gitlab_apps'
  delete '/oauth/github/apps/:id', to: 'linked_apps#github_delete', as: 'delete_linked_github_app'
  delete '/oauth/gitlab/apps/:id', to: 'linked_apps#gitlab_delete', as: 'delete_linked_gitlab_app'

  # Github Code Repos
  get '/linked_apps/github/:id/repos', to: 'linked_apps#github_repos_for_app'

  # Gitlab Code Repos
  get '/linked_apps/gitlab/:id/repos', to: 'linked_apps#gitlab_repos_for_app'

  # Docker Registry Repos
  get '/linked_apps/github/:id/repos', to: 'linked_apps#github_repos_for_app'

  # OAuth Callbacks
  get '/oauth/github/callback', to: 'linked_apps#github_success', as: 'github_oauth_callback'
  get '/oauth/gitlab/callback', to: 'linked_apps#gitlab_success', as: 'gitlab_oauth_callback'

  # Webhooks
  post '/github/webhooks/:id/', to: 'webhooks#github', as: 'github_webhook'
  post '/gitlab/webhooks/:id/', to: 'webhooks#gitlab', as: 'gitlab_webhook'

  get '/build_jobs', to: 'build_jobs#index', as: 'build_jobs'
  get '/build_jobs/:id/dockerfile', to: 'build_jobs#dockerfile', as: 'build_job_dockerfile'
  get '/build_jobs/:id/logs', to: 'build_jobs#logs', as: 'build_job_logs'

  root to: 'build_jobs#index'
  if Rails.env.development?
    mount Sidekiq::Web => "/sidekiq"
  end
end
