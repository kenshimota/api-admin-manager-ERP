class DashboardController < VerifyAuthenticateController
  
  
  def summary
    response = {}
    
    start_month = Time.zone.now.beginning_of_month
    end_month = Time.zone.now.end_of_month
    today_range =  Time.zone.now.beginning_of_day..Time.zone.now.end_of_day

    status_invoiced = OrdersStatus.find_by(name: ORDER_STATUSES_NAME[:invoiced])

    response[:total_users] = User.count
    response[:total_products_with_stock] = Product.where("stock > 0").count
    response[:total_products_without_stock] = Product.where("stock = 0").count


    response[:total_invoices_today] = Order.where(
      orders_status_id: status_invoiced.id, 
      created_at: today_range
    ).count

    response[:total_invoices_month] = Order.where(created_at: start_month..end_month).count

    response[:total_orders_today] = Order.where(
      created_at: today_range
    ).count

    response[:total_products_bought_today] = Product.where( id: OrdersItem.select(:product_id).where(created_at: today_range)  ).count
    response[:total_products_bought_month] = Product.where( id: OrdersItem.select(:product_id).where(created_at: start_month..end_month ) ).count
    
    
    response[:total_orders_month] = Order.where(
      created_at: start_month..end_month
    ).count


    render json: response
  end
end
