Rails.application.routes.draw do
  resources :investments do
    collection do
      get 'index2'
    end
  end
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
