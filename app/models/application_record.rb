class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  scope :order_field, lambda { |order_by|
    if order_by.nil? || !order_by.is_a?(ActionController::Parameters)
      return self
    end

    fields = self.attribute_names.filter { |field| field.split("_").last != "id" }
    set = Set.new fields
    valid_by = Set.new [:asc, :desc]

    if !set.include?(order_by[:field])
      return self
    end

    v = {}
    by = order_by[:order].to_s
    by = valid_by.include?(by) ? by : :asc

    v[order_by[:field].to_s] = by
    order(v)
  }
end
