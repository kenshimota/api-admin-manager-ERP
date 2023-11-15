class Supplier < ApplicationRecord
  belongs_to :city
  belongs_to :state
end
