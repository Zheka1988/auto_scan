require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :users
  mount Sidekiq::Web => '/sidekiq'

  root to: 'countries#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :countries do
    member do
      get 'get_cidr'
      get 'scan_open_ports'
      get 'download_cidr'
      get 'scan_ftp_anonymous'
    end
    resources :ip_addresses, shallow: true, only: [:index]
    resources :ftp_results, shallow: true, only: [:index]
  end


end
