Rails.application.routes.draw do
  resources :users do
    resources :articles do
      resources :tags
    end
  end
  post "/login", to: "auth#login"
end
