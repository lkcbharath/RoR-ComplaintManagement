Rails.application.routes.draw do
  devise_for :users
  resources :complaints do
    member do
      patch :update_status
    end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  root 'complaints#index'
end
