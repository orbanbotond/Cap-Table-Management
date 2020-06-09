Rails.application.routes.draw do
  devise_for :users
  resources :investments do
    collection do
      get 'index2'
    end
  end

  root to: redirect('investments')
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
