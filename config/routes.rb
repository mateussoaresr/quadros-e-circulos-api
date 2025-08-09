Rails.application.routes.draw do
  resources :frames, only: [ :create ]

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
end
