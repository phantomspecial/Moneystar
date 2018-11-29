Rails.application.routes.draw do
  devise_for :users
  as :user do
    get 'users/edit' => 'devise/registrations#edit', :as => 'edit_user_registration'
    put 'users' => 'devise/registrations#update', :as => 'user_registration'
  end

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

  resources :budgets

  resources :budget_performances, only: :index
end
