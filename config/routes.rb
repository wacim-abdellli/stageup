Rails.application.routes.draw do
  # Redirect default Devise registration routes to our custom onboarding flow
  get 'users/sign_up', to: redirect('/signup')
  get 'users', to: redirect('/signup')

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

  resource :dashboard, only: [:show] do
    patch :update_cv
  end
  resources :offers
  resources :submissions, only: [:create, :edit, :update] do
    member do
      post :accept
      post :reject
      post :confirm_completion
      post :abandon
      post :cancel
    end
    resources :reviews, only: [:new, :create]
    resources :internship_agreements, only: [:new, :create, :show] do
      member do
        post :sign
        post :decline
      end
    end
  end
  resources :notifications, only: [:index, :update] do
    collection do
      post :read_all
    end
  end
  root to: "home#index"
  get 'reputation_events', to: 'home#reputation_events'

  namespace :admin do
    get 'dashboard', to: 'dashboards#index', as: :dashboard
    resources :university_profiles, only: [] do
      post :approve, on: :member
      post :reject, on: :member
    end
    resources :company_profiles, only: [] do
      post :verify, on: :member
      post :unverify, on: :member
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
