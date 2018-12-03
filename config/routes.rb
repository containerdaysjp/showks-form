Rails.application.routes.draw do
  resources :projects do
    collection do
      get 'create_demoaccount'  #for test
      get 'destroy_demoaccount'
    end
  end
  root to: "projects#new"
  # resources :projects, only: [:new] do
  #   resources :admin, only: [:index]
  # end
end
