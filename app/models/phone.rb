class Phone < ApplicationRecord
  validates :prefix, presence: true
  validates :number, presence: true, uniqueness: { scope: :prefix }
  validates_numericality_of :prefix, less_than_or_equal_to: 999, greater_than: 0
  validates_numericality_of :number, less_than_or_equal_to: 10 ** 11, greater_than_or_equal_to: 10 ** 8
end
