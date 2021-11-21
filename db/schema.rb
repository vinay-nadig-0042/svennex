# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_11_04_211026) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pgcrypto"
  enable_extension "plpgsql"

  create_table "autobuilds", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "code_repo_name"
    t.string "code_repo_type"
    t.json "rules", default: []
    t.json "webhook_config"
    t.string "webhook_secret"
    t.json "env_vars", default: []
    t.uuid "user_id"
    t.uuid "github_linked_app_id"
    t.uuid "gitlab_linked_app_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["github_linked_app_id"], name: "index_autobuilds_on_github_linked_app_id"
    t.index ["gitlab_linked_app_id"], name: "index_autobuilds_on_gitlab_linked_app_id"
    t.index ["user_id"], name: "index_autobuilds_on_user_id"
  end

  create_table "autobuilds_docker_hub_registries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "autobuild_id"
    t.uuid "docker_hub_registry_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["autobuild_id"], name: "index_autobuilds_docker_hub_registries_on_autobuild_id"
    t.index ["docker_hub_registry_id"], name: "idx_autobuilds_dkr_hub_regs_on_dkr_hub_reg_id"
  end

  create_table "build_jobs", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "complete", default: false
    t.string "status"
    t.text "failure_reason"
    t.integer "image_size"
    t.integer "duration", default: 0
    t.json "matched_rule", default: {}
    t.string "dockerfile_path"
    t.string "build_logs_path"
    t.string "docker_tag"
    t.string "commit_sha"
    t.string "image_uri"
    t.string "source_repo"
    t.uuid "autobuild_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["autobuild_id"], name: "index_build_jobs_on_autobuild_id"
  end

  create_table "docker_hub_registries", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.string "access_token"
    t.string "username"
    t.string "repo_name"
    t.string "verification_status", default: "pending"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_docker_hub_registries_on_user_id"
  end

  create_table "github_linked_apps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token"
    t.string "username"
    t.string "url"
    t.string "status"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_github_linked_apps_on_user_id"
    t.index ["username"], name: "index_github_linked_apps_on_username"
  end

  create_table "github_repositories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "github_id"
    t.string "name"
    t.string "full_name"
    t.boolean "private"
    t.string "http_url"
    t.text "description"
    t.string "api_url"
    t.string "git_url"
    t.string "ssh_url"
    t.string "clone_url"
    t.uuid "autobuild_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["autobuild_id"], name: "index_github_repositories_on_autobuild_id"
  end

  create_table "gitlab_linked_apps", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_token"
    t.string "refresh_token"
    t.string "username"
    t.string "url"
    t.string "status"
    t.uuid "user_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["user_id"], name: "index_gitlab_linked_apps_on_user_id"
    t.index ["username"], name: "index_gitlab_linked_apps_on_username"
  end

  create_table "gitlab_repositories", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "name"
    t.string "git_url"
    t.string "http_url"
    t.string "ssh_url"
    t.uuid "autobuild_id"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["autobuild_id"], name: "index_gitlab_repositories_on_autobuild_id"
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

end
