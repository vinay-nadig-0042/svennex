class AddGithubRepo < ActiveRecord::Migration[6.1]
  def change
    create_table :github_repositories, id: :uuid do |t|
      t.string :github_id
      t.string :name
      t.string :full_name
      t.boolean :private
      t.string :http_url
      t.text :description
      t.string :api_url
      t.string :git_url
      t.string :ssh_url
      t.string :clone_url

      t.belongs_to :autobuild, type: :uuid
      t.timestamps
    end
  end
end
