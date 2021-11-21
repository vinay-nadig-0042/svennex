class Autobuild < ApplicationRecord
  belongs_to :user
  belongs_to :github_linked_app, optional: true
  belongs_to :gitlab_linked_app, optional: true
  has_and_belongs_to_many :docker_hub_registries
  has_one :github_repository
  has_one :gitlab_repository
  has_many :build_jobs
  # has_one :gitlab_repository

  # TODO: What other kind of validations do we need for different rule combinations?
  validates :name, presence: true
  validates :code_repo_name, presence: true, exclusion: { in: ["Select Github Repo"], message: "should be selected" }
  validates :code_repo_type, presence: true, exclusion: { in: ["Select Github Repo"], message: "should be selected" }
  validates :docker_hub_registries, length: { minimum: 1, maximum: 1, message: "can't be empty" }
  validate  :rules_cant_be_empty, :source_type_is_tag_or_branch,
            :source_is_valid, :docker_tag_is_valid, :dockerfile_is_valid,
            :build_context_is_valid, :at_least_one_linked_app

  after_create :create_repo_webhook
  before_destroy :remove_repo_webhook

  def rules_cant_be_empty
    rules.count == 0 ? errors.add(:rules, "can't be empty.") : nil
  end

  def source_type_is_tag_or_branch
    unless rules&.all? { |rule| ["tag", "branch"].include? rule.dig("source_type") }
      errors.add(:rules, "source type should be either tag or branch.")
    end
  end

  def source_is_valid
    if rules&.any? { |rule| rule.dig("source").blank? }
      errors.add(:rules, "source can't be empty.")
    end
  end

  def docker_tag_is_valid
    if rules&.any? { |rule| rule.dig("docker_tag").blank? }
      errors.add(:rules, "docker tag can't be empty.")
    end
  end

  def dockerfile_is_valid
    if rules&.any? { |rule| rule.dig("dockerfile").blank? }
      errors.add(:rules, "Dockerfile can't be empty.")
    end
  end

  def build_context_is_valid
    if rules&.any? { |rule| rule.dig("build_context").blank? }
      errors.add(:rules, "build context can't be empty.")
    end
  end

  def at_least_one_linked_app
    if gitlab_linked_app.blank? && github_linked_app.blank?
      errors.add(:code_repo, "configure at least one code repo for autobuild")
    end
  end

  def create_repo_webhook
    CreateRepoWebhookWorker.perform_async(self.id)
  end

  def remove_repo_webhook
    webhook_id = webhook_config.to_h.dig("id")
    linked_app_id = code_repo_type == 'github' ? github_linked_app.id : gitlab_linked_app.id
    RemoveRepoWebhookWorker.perform_async(code_repo_type, code_repo_name, webhook_id, linked_app_id)
  end
end
