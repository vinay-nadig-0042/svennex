class DockerHubRegistriesController < ApplicationController
  before_action :set_docker_hub_registry, only: %i[ edit update destroy ]

  def index
    @docker_hub_registries = current_user.docker_hub_registries.paginate(page: params[:page], per_page: 10)
  end

  def new
    @docker_hub_registry = current_user.docker_hub_registries.new
  end

  def edit
  end

  def create
    @docker_hub_registry = current_user.docker_hub_registries.new(docker_hub_registry_params)
    if @docker_hub_registry.save
      redirect_to docker_hub_registries_path, notice: "Docker hub registry was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @docker_hub_registry.update(docker_hub_registry_params)
      redirect_to docker_hub_registries_path, notice: "Docker hub registry was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @docker_hub_registry.destroy
    redirect_to docker_hub_registries_url, notice: "Docker hub registry was successfully destroyed."
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_docker_hub_registry
      @docker_hub_registry = current_user.docker_hub_registries.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def docker_hub_registry_params
      params.require(:docker_hub_registry).permit(
        :name,
        :description,
        :username,
        :repo_name,
        :access_token
      )
    end
end
