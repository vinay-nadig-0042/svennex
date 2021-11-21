class AddAutobuilds < ActiveRecord::Migration[6.1]
  def change
    create_table :autobuilds, id: :uuid do |t|
      t.string :name
      t.string :description
      t.string :code_repo_name
      t.string :code_repo_type
      t.json :rules, default: []
      t.json :webhook_config
      t.string :webhook_secret
      t.json :env_vars, default: []

      t.belongs_to :user, type: :uuid
      t.belongs_to :github_linked_app, type: :uuid
      t.belongs_to :gitlab_linked_app, type: :uuid
      t.timestamps
    end
  end
end
