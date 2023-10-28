FactoryBot.define do
  factory :orders_status_pending, class: OrdersStatus do
    name { ORDER_STATUSES_NAME[:pending] }
  end

  factory :orders_status_invoiced, class: OrdersStatus do
    name { ORDER_STATUSES_NAME[:invoiced] }
  end

  factory :orders_status_canceled, class: OrdersStatus do
    name { ORDER_STATUSES_NAME[:canceled] }
  end
end
