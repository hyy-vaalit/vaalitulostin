Vaalit::Application.routes.draw do

  ActiveAdmin.routes(self)

  devise_for :admin_users, ActiveAdmin::Devise.config

  resources :listings, :only => [] do
    collection do
      get :simple
      get :same_ssn
    end
  end

  resource :voting_area, :only => [:show] do
    member do
      get :login
      post :login, :action => :login_post
    end
  end

end
