Rails.application.routes.draw do
  devise_for :users
  root 'masters#index'

  resources :masters, only: [:index]

  resources :journals, only: [:index, :new, :create]

  resources :ledgers, only: [:index]

  resources :categories, only: [:index, :new, :create, :edit, :update]

  resources :csv_includes, only: [] do
    collection do
      get 'reading'
      post 'forward_data'
      post 'journal_data'
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

  resources :monthly_finance, only: [:index]
end
