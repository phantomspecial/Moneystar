Rails.application.routes.draw do
  root 'masters#index'

  resources :masters, only: [:index]

  resources :journals, only: [:index, :new, :create]

  resources :ledgers, only: [:index]

  resources :categories, only: [:index, :new, :create, :edit, :update]

  resources :searches, only: [:index] do
    collection do
      get 'result'
      get 'download'
    end
  end

  resources :settlements, only: [] do
    collection do
      get 'trial'
      get 'profit'
      get 'balance'
      get 'cashflow'
      get 'download'
    end
  end
end
