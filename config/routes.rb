Rails.application.routes.draw do
  resources :frames, only: [ :create, :show, :destroy ] do
    resources :circles, only: [ :create ]
  end

  resources :circles, only: [ :update, :index, :destroy ]

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
end
