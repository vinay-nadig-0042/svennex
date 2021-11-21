class AddDockerHubRegistry < ActiveRecord::Migration[6.1]
  def change
    create_table :docker_hub_registries, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :access_token
      t.string :username
      t.string :repo_name
      t.string :verification_status, default: 'pending'

      t.belongs_to :user, type: :uuid
      t.timestamps
    end
  end
end
