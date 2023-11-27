class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse
  has_many :inventories_histories, dependent: :destroy

  before_create :load_reserved
  before_create :before_create_inventory
  after_create :after_create_inventory
  before_destroy :before_destroy_inventory

  validates :stock, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :reserved, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :product_id, presence: true, uniqueness: { scope: :warehouse_id }
  validate :check_if_reserved_is_greater_than_stock

  scope :filter_product, ->(product_id) { product_id ? where(product_id: product_id) : self }
  scope :metadata, ->(check) { joins(:product, :warehouse).includes(:product, :warehouse) if check }
  scope :filter_warehouse, ->(warehouse_id) { warehouse_id ? where(warehouse_id: warehouse_id) : self }
  scope :search, ->(q) { where(warehouse: Warehouse.search(q)).or(where(product: Product.where("CONCAT(UPPER(name), ' ', UPPER(code)) LIKE UPPER(?)", "%#{q}%"))) if q and !q.empty? }

  def set_user(current_user)
    @user = current_user
  end

  def reserve_stock!(amount)
    if amount != 0
      self.increment! :reserved, amount
      touch(:updated_at)

      self.validate
      raise ActiveRecord::RecordInvalid.new(self) if errors.present?

      self.product.increment! :reserved, amount
      self.product.touch(:updated_at)
    end

    self
  end

  def reserve_stock(amount)
    ActiveRecord::Base.transaction do
      self.reserve_stock! amount
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::Rollback
    end

    errors.present? == false
  end

  def increment_stock!(amount)
    if amount != 0
      @stock = self.stock

      self.increment! :stock, amount
      touch(:updated_at)

      self.validate
      raise ActiveRecord::RecordInvalid.new(self) if errors.present?

      self.product.increment! :stock, amount
      self.product.touch(:updated_at)

      InventoriesHistory.create!(
        user: @user,
        inventory: self,
        before_amount: @stock,
        after_amount: @stock + amount,
        observations: self.observations,
      )
    end

    self
  end

  def increment_stock(amount)
    ActiveRecord::Base.transaction do
      self.increment_stock! amount
    rescue ActiveRecord::RecordInvalid => e
      raise ActiveRecord::Rollback
    end

    errors.present? == false
  end

  def available
    self.stock - self.reserved
  end

  private

  def before_create_inventory
    self.reserved = 0
  end

  def before_destroy_inventory
    if self.reserved > 0
      errors.add(:reserved, I18n.t(:inventory_dont_delete))
    end

    throw(:abort) if self.errors.present?

    self.product.lock!
    self.product.increment! :stock, -self.stock
  end

  def after_create_inventory
    self.product.increment! :stock, self.stock
    InventoriesHistory.create!(
      user: @user,
      inventory: self,
      after_amount: self.stock,
      observations: self.observations,
    )
  end

  def check_if_reserved_is_greater_than_stock
    if self.reserved > self.stock
      errors.add(:reserved, I18n.translate(:reserved_is_greater_than_stock))
    end
  end

  def load_reserved
    self.reserved = 0
  end
end
