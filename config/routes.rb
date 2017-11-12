Rails.application.routes.draw do
  root to: 'welcome#index'
  resources :achievements, only: [:new, :create]
end
