Vaalitulostin::Application.routes.draw do

  # Devise routes must be on top to get highest priority
  devise_for :admin_users

  root :to => "public#index"

  resource :dashboard, controller: 'dashboard'

  namespace :manage do
    resources :voters, :only => [:index, :create] do
      post :send_link, on: :collection
    end

    resources :results, :only => [:index, :show] do
      put :publish
      put :freeze, on: :collection
      put :fetch_votes, on: :collection
    end
  end

  namespace :draws, :as => "" do
    get :index, :as => :draws
    resources :coalitions, :as => :coalition_draws
    resources :alliances, :as => :alliance_draws
    resources :candidates, :as => :candidate_draws
    post :candidate_draws_ready
    post :alliance_draws_ready
    post :coalition_draws_ready
  end

end
