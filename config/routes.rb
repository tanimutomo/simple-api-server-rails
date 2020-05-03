Rails.application.routes.draw do
  resources :users do
    resources :articles do
      get '/tags', to: 'tags#index_article'
      post '/tags', to: 'tags#create'
      delete '/tags/:id', to: 'tags#delete'
    end
    get '/tags', to: 'tags#index_user'
  end
  post '/login', to: 'auth#login'
end
