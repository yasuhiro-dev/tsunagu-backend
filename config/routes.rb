Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"
      post "/login", to: "sessions#create"
    end
  end
end
