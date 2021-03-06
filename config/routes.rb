Rails.application.routes.draw do
  namespace :api do
    mount_devise_token_auth_for 'User', at: 'auth', controllers: {
      registrations: 'api/auth/registrations'
    }
    namespace :v1 do
      resources :tasks, only: [:index, :show, :create, :update, :destroy]
    end
  end

  root  'rails/welcome#index'
  post  '/line_events', to: 'linebots#getLinkToken'
  post  '/callback', to: 'linebots#callback'
end
