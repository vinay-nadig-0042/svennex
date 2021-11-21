class DockerHubRegistry < ApplicationRecord
  belongs_to :user
  has_and_belongs_to_many :autobuilds

  validates :name, presence: true
  validates :username, presence: true
  validates :repo_name, presence: true
  validates :access_token, presence: true

  after_create :verify_registry_access

  def verify_registry_access
    VerifyDockerHubRegistryAccessWorker.perform_async(id)
  end
end