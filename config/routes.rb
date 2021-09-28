require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :countries do
    member do
      get 'get_cidr'
      get 'scan_open_ports'
    end
  end
end
