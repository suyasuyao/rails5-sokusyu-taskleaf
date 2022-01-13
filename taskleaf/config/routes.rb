Rails.application.routes.draw do
  get 'sessions/new'
  namespace :admin do
    resources :users
  end
  resources :tasks
  # トップページにtaskのindexページを表示
  root to: 'tasks#index'
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
