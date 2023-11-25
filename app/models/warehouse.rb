class Warehouse < ApplicationRecord
  validates :name, presence: :true, uniqueness: { case_sensitive: false }
  before_destroy :destroy_warehouse

  scope :search, lambda { |search|
    if !search
      return self
    end

    where("UPPER(name) LIKE UPPER(?)", "%#{search}%")
      .or(where("UPPER(address) LIKE UPPER(?)", "%#{search}%"))
  }

  private

  def destroy_warehouse
    first = Inventory.where(warehouse_id: self.id).first
    throw(:abort) if first.nil? == false
  end
end
