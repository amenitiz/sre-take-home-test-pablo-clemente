Rails.application.routes.draw do
  resources :services

  get "healthz" => "health#show"

  # Rails built-in health check
  get "up" => "rails/health#show", as: :rails_health_check

  root "services#index"
end
