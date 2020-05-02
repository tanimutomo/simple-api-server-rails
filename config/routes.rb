Rails.application.routes.draw do
  resources :users do
    resources :articles do
      get "/tags/:id", to: "tags#show"
      post "/tags", to: "tags#create"
      delete "/tags/:id", to: "tags#destroy"
    end
    get "/tags", to: "tags#index"
  end
  post "/login", to: "auth#login"
end
