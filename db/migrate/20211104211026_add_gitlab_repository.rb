class AddGitlabRepository < ActiveRecord::Migration[6.1]
  def change
    create_table :gitlab_repositories, id: :uuid do |t|
      t.string :name
      t.string :git_url
      t.string :http_url
      t.string :ssh_url

      t.belongs_to :autobuild, type: :uuid
      t.timestamps
    end
  end
end
