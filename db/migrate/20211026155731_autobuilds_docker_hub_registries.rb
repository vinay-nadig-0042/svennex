class AutobuildsDockerHubRegistries < ActiveRecord::Migration[6.1]
  def change
    create_table :autobuilds_docker_hub_registries, id: :uuid do |t|
      t.belongs_to :autobuild, type: :uuid
      t.belongs_to :docker_hub_registry, type: :uuid, index: { name: 'idx_autobuilds_dkr_hub_regs_on_dkr_hub_reg_id' }
      t.timestamps
    end
  end
end
