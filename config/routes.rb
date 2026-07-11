Rails.application.routes.draw do
  devise_for :users, controllers: { registrations: 'users/registrations' }

  devise_scope :user do
    get 'signup', to: 'users/registrations#select_role', as: :select_role
    get 'signup/student', to: 'users/registrations#new_student', as: :new_student_registration
    post 'signup/student', to: 'users/registrations#create_student', as: :student_registration
    get 'signup/company', to: 'users/registrations#new_company', as: :new_company_registration
    post 'signup/company', to: 'users/registrations#create_company', as: :company_registration
    get 'signup/university', to: 'users/registrations#new_university', as: :new_university_registration
    post 'signup/university', to: 'users/registrations#create_university', as: :university_registration
  end

  resource :dashboard, only: [:show]
  resources :offers
  resources :submissions, only: [:create, :edit, :update] do
    member do
      post :accept
      post :reject
      post :confirm_completion
    end
    resources :reviews, only: [:new, :create]
  end
  root to: "dashboards#show"

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
