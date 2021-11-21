class AutobuildsController < ApplicationController
  before_action :set_autobuild, only: %i[ edit update destroy ]

  def index
    @autobuilds = current_user.autobuilds.paginate(page: params[:page], per_page: 10)
  end

  def new
    @autobuild = current_user.autobuilds.new
    @github_linked_apps = current_user.github_linked_apps
    @gitlab_linked_apps = current_user.gitlab_linked_apps
    @docker_hub_registries = current_user.docker_hub_registries
  end

  def edit
  end

  def create
    @github_linked_apps = current_user.github_linked_apps
    @docker_hub_registries = current_user.docker_hub_registries
    @autobuild = current_user.autobuilds.create({
      name: autobuild_params["name"],
      description: autobuild_params["description"],
      github_linked_app: current_user.github_linked_apps.where(id: autobuild_params["github_linked_app"]).first,
      gitlab_linked_app: current_user.gitlab_linked_apps.where(id: autobuild_params["gitlab_linked_app"]).first,
      docker_hub_registries: current_user.docker_hub_registries.where(id: autobuild_params["docker_registry"]).to_a,
      code_repo_name: autobuild_params["code_repo_name"],
      code_repo_type: autobuild_params["code_repo_type"],
      rules: autobuild_params["rules"]&.values.to_a.first(10), # TODO: Make this configurable,
      env_vars: autobuild_params["env_vars"]&.values.to_a.first(20) # TODO: Make this configurable,
    })
    if @autobuild.save
      redirect_to autobuilds_path, notice: "Autobuild was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @github_linked_apps = current_user.github_linked_apps
    @docker_hub_registries = current_user.docker_hub_registries
    if @autobuild.update({
      name: autobuild_params["name"],
      description: autobuild_params["description"],
      rules: autobuild_params["rules"]&.values.to_a.first(10), # TODO: Make this configurable
      env_vars: autobuild_params["env_vars"]&.values.to_a.first(20) # TODO: Make this configurable,
    })
      redirect_to autobuilds_path, notice: "Autobuild was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @autobuild.destroy
    redirect_to autobuilds_path, notice: "Autobuild was successfully destroyed."
  end

  private
    def set_autobuild
      @autobuild = current_user.autobuilds.find(params[:id])
    end

    def autobuild_params
      raw_params = params.require(:autobuild).permit(
        :name,
        :description,
        :docker_registry,
        :github_linked_app,
        :gitlab_linked_app,
        :code_repo_type,
        :code_repo_name,
        {
          env_vars: [
            :key,
            :value
          ]
        },
        {
          rules: [
            :source_type,
            :source,
            :docker_tag,
            :dockerfile,
            :build_context,
            :autobuild
          ]
        }
      )

      # autobuild checkboxes ar returned as "0" & "1"
      # instead of "false" & "true". So, let's cast it to boolean
      # TODO: Better way to do this?
      raw_params["rules"]&.values.to_a.each do |rule|
        rule["autobuild"] = ActiveModel::Type::Boolean.new.cast(rule["autobuild"])
      end

      raw_params
    end
end
