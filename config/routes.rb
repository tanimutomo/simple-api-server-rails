Rails.application.routes.draw do
  resources :tags
  resources :users do
    resources :articles do
      get "/tags/:id", to: "tags#show"
      post "/tags", to: "tags#create"
      delete "/tags/:id", to: "tags#destroy"
    end
    get "/tags", to: "tags#index"
  end
  post "/auth/login" to: 
end
