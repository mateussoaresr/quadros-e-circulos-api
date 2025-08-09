Rails.application.routes.draw do
  resources :frames, only: [ :create ] do
    resources :circles, only: [ :create ]
  end

  resources :circles, only: [ :update, :index ] # index = GET /circles (listagem com filtro)

  mount Rswag::Api::Engine => "/api-docs"
  mount Rswag::Ui::Engine => "/api-docs"
end
