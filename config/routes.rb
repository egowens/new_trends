Rails.application.routes.draw do
  #Sessions routes
  controller :sessions do
    get 'login' => :new
    post 'login' => :create
    get 'auth/shopify/callback' => :show
    delete 'logout' => :destroy
  end

  #Collection routes
  resources :collection

  #Live collection routes
  resources :live_collection

  #support page
  get '/support',   to: 'home#support'

  #Set root path
  root :to => 'home#index'

  #redirect all unknown paths to root
  get "*path" => redirect("/")
end
