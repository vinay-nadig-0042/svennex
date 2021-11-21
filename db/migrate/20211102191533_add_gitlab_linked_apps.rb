class AddGitlabLinkedApps < ActiveRecord::Migration[6.1]
  def change
    create_table :gitlab_linked_apps, id: :uuid do |t|
      t.string :access_token
      t.string :refresh_token
      t.string :username, index: true
      t.string :url
      t.string :status #TODO: Add a default here?
      t.belongs_to :user, type: :uuid, index: true

      t.timestamps
    end
  end
end
