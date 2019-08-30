Rails.application.routes.draw do

  resources :events, only: [:create, :destroy]
end
