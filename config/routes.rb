Rails.application.routes.draw do
  resources :projects, only: [:new, :create, :destroy] do
    collection do
      get 'create_demoaccount'  #for test
      get 'destroy_demoaccount'
      get 'admin/list', to: 'projects#index'
    end
  end
  root to: "projects#new"
  # resources :projects, only: [:new] do
  #   resources :admin, only: [:index]
  # end
end
