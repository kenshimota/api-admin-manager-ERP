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

    resources :taxes, except: [:show]
    resources :cities, only: [:index]
    resources :states, only: [:index]
    resources :products
    resources :customers
    resources :orders, only: [:show, :index, :destroy]
    resources :warehouses
    resources :currencies
    resources :inventories
    resources :products_prices
    resources :orders_items, except: [:update]
    resources :inventories_histories, only: [:index]
    resources :products_prices_histories, only: [:index, :show]
  end
end
