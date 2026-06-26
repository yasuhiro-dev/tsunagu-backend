Rails.application.routes.draw do
  get "/up", to: proc { [ 200, {}, [ "OK" ] ] }
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
      delete "/admin/parents/bulk_destroy", to: "admin#bulk_destroy"
      delete "/admin/teachers/bulk_destroy", to: "admin#bulk_teacher_destroy"
      delete "/admin/teachers/:id", to: "admin#destroy"
      delete "/admin/parents/:id", to: "admin#destroy"
      get "/admin/parents/:id", to: "admin#show_parent"
      patch "/admin/parents/:id", to: "admin#update_parent"
      patch "/admin/teachers/:id", to: "admin#update_teacher"
      post "/admin/parents", to: "admin#create_parent"
      patch "/family_unavailabilities/:family_id", to: "family_unavailabilities#update"
      get "child_list", to: "children#index"
      get "/families/:id", to: "families#show"
      get "/children/unassigned", to: "children#unassigned"
      post "/assignments", to: "assignments#create"
      post "/password_resets", to: "password_resets#create"
      patch "/password_resets/:token", to: "password_resets#update"
    end
  end
end
