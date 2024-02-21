class UsersRole < ApplicationRecord
  belongs_to :user
  belongs_to :role
  validates :user_id, presence: true, uniqueness: { case_sensitive: false }
end
