class AddBuildJobs < ActiveRecord::Migration[6.1]
  def change
    create_table :build_jobs, id: :uuid do |t|
      t.boolean :complete, default: false
      t.string :status
      t.text :failure_reason
      t.integer :image_size
      t.integer :duration, default: 0
      t.json :matched_rule, default: {}
      t.string :dockerfile_path
      t.string :build_logs_path
      t.string :docker_tag
      t.string :commit_sha
      t.string :image_uri
      t.string :source_repo
      t.belongs_to :autobuild, type: :uuid

      t.timestamps
    end
  end
end
