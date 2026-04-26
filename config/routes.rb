Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"
      post "/login", to: "sessions#create"
      get "/meeting_slots", to: "meeting_slots#index"
      post "/users", to: "users#create"
      get "/family_unavailabilities", to: "family_unavailabilities#index"
      post "/family_unavailabilities", to: "family_unavailabilities#create"
      delete "/family_unavailabilities/:meeting_slot_id", to: "family_unavailabilities#destroy"
    end
  end
end
