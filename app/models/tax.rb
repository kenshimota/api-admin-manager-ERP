class Tax < ApplicationRecord
  before_destroy :destroy_tax

  validates :name, presence: :true, uniqueness: { case_sensitive: false }
  validates :percentage, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 1 }, uniqueness: true
  scope :search, ->(search) { search ? where("UPPER(taxes.name) LIKE UPPER(?)", "%#{search}%") : self }

  private

  def destroy_tax
    first = Product.where(tax_id: self.id).first
    throw(:abort) if first.nil? == false
  end
end
