Vaalitulostin::Application.routes.draw do

  # Devise routes must be on top to get highest priority
  #TODO: devise_for :who_is_the_user

  root :to => "public#index"

  namespace :manage do
    resources :results, :only => [:index, :show] do
      put :publish
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
