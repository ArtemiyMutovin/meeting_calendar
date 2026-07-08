Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  resources :employees, only: [:index, :create, :destroy]
  resources :meetings, only: [:index, :new, :create, :show, :destroy]

  root "meetings#index"
end
