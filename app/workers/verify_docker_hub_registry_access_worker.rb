class VerifyDockerHubRegistryAccessWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: false

  def perform(docker_hub_reg_id)
    docker_registry = DockerHubRegistry.find(docker_hub_reg_id)
    begin
      Docker.authenticate!(username: docker_registry.username, password: docker_registry.access_token)
    rescue Docker::Error::AuthenticationError => e
      docker_registry.update(verification_status: 'failed')
      raise e
    end
    docker_registry.update(verification_status: 'complete')
  end
end