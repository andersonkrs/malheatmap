require "sidekiq/web"

Rails.application.routes.draw do
  resources :subscriptions, only: %i[create index]
  resources :users, only: %i[show]

  mount Sidekiq::Web => "/sidekiq"
end
