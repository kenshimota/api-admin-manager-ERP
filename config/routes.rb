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

    devise_scope :user do
      post :reset_passwords, to: "passwords#create"
      put :reset_passwords, to: "passwords#update"
      patch :reset_passwords, to: "passwords#update"
    end

    get 'dashboard/summary'

    resources :taxes, except: [:show]
    resources :cities, only: [:index]
    resources :states, only: [:index]
    resources :products
    resources :customers
    resources :orders, except: [:update]
    resources :warehouses
    resources :currencies
    resources :inventories
    resources :products_prices
    resources :invoices, only: [:create]
    resources :orders_items, except: [:update]
    resources :inventories_histories, only: [:index]
    resources :products_prices_histories, only: [:index, :show]
  end
end
