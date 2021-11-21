class GithubLinkedApp < ApplicationRecord
  belongs_to :user
  validates :username, uniqueness: { scope: [:user_id] }
end