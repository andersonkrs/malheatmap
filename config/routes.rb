require "sidekiq/web"

Rails.application.routes.draw do
  root to: "subscriptions#index"

  resources :subscriptions, only: %i[create index]
  resources :users, only: :show, param: :username do
    resource :signature, only: :show, on: :member
  end

  get "/about", to: "application#about", as: "about"
  get "/faq", to: "application#faq", as: "faq"
  match "/404" => "application#not_found", via: :all, as: "not_found"
  match "/500" => "application#internal_error", via: :all, as: "internal_error"

  mount Sidekiq::Web => "/sidekiq"
end
