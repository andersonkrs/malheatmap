require "sidekiq/web"

Rails.application.routes.draw do
  root to: "subscriptions#index"

  resources :subscriptions, only: %i[create index]
  resources :users, only: :show, param: :username do
    resource :signature, only: :show, on: :member
  end

  match "/404" => "errors#not_found", via: :all, as: "not_found"
  match "/500" => "errors#internal_error", via: :all, as: "internal_error"

  mount Sidekiq::Web => "/sidekiq"
end
