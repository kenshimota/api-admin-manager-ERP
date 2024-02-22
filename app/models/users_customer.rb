class UsersCustomer < ApplicationRecord
  belongs_to :user
  belongs_to :customer

  validates :user_id, presence: true, uniqueness: { case_sensitive: false }
  validates :customer_id, presence: true, uniqueness: { case_sensitive: false }
end
