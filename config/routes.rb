Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Defines the root path route ("/")
  # root "articles#index"

  scope :api, :defaults => { :format => "json" } do
    devise_for :users, {
      controllers: {
        sessions: "users/sessions",
        registrations: "users/registrations",
      },
    }

    resources :taxes
    resources :cities
    resources :states
    resources :products
    resources :customers
    resources :warehouses
    resources :currencies
    resources :inventories
    resources :products_prices
    resources :inventories_histories
    resources :products_prices_histories
  end
end
