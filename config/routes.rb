Rails.application.routes.draw do
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"
      post "/login", to: "sessions#create"
      get "/meeting_slots", to: "meeting_slots#index"
      get "/family_unavailabilities", to: "family_unavailabilities#index"
      post "/family_unavailabilities", to: "family_unavailabilities#create"
      delete "/family_unavailabilities/:meeting_slot_id", to: "family_unavailabilities#destroy"
      post "/schedules", to: "schedules#create"
      get "/all_meeting_slots", to: "meeting_slots#all"
      get "/admin/users", to: "admin#index"
      get "/class_rooms", to: "class_rooms#index"
      post "/users/parent", to: "users#create_parent"
      post "/admin/teachers", to: "admin#create_teacher"
    end
  end
end
