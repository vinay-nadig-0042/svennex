class User < ApplicationRecord
  @@devise_modules = [:database_authenticatable, :registerable, :recoverable, :rememberable, :validatable]

  if Rails.env.development?
    devise *@@devise_modules
  else
    @@devise_modules << :confirmable
    devise *@@devise_modules << :confirmable
  end

  has_many :autobuilds
  has_many :docker_hub_registries
  has_many :github_linked_apps
  has_many :gitlab_linked_apps
  has_many :build_jobs, through: :autobuilds
end
