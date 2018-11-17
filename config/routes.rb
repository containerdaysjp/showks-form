Rails.application.routes.draw do
  resources :projects
  # resources :projects, only: [:new] do
  #   resources :admin, only: [:index]
  # end
end
