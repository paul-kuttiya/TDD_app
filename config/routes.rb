Rails.application.routes.draw do
  devise_for :users
  root to: 'welcome#index'
  resources :achievements

  namespace :api do
    resources :achievements, only: [:index]
  end
end
