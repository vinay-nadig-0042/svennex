class AddGithubLinkedApps < ActiveRecord::Migration[6.1]
  def change
    create_table :github_linked_apps, id: :uuid do |t|
      t.string :access_token
      t.string :username, index: true
      t.string :url
      t.string :status #TODO: Add a default here?
      t.belongs_to :user, type: :uuid, index: true

      t.timestamps
    end
  end
end
