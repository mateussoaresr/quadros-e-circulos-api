Rails.application.routes.draw do
  resources :frames, only: [ :create, :show ] do
    resources :circles, only: [ :create ]
  end

  resources :circles, only: [ :update, :index ]

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
end
