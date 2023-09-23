class CustomersPhone < ApplicationRecord
  belongs_to :customer
  belongs_to :phone

  validates :customer_id, presence: true
  validates :phone_id, presence: true, uniqueness: { scope: :customer_id }
end
