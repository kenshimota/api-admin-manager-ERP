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
  end
end
