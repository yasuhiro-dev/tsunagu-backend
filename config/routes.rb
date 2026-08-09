Rails.application.routes.draw do
  get "/up", to: proc { [ 200, {}, [ "OK" ] ] }
  namespace :api do
    namespace :v1 do
      get "health_check", to: "health_check#index"
      post "/login", to: "sessions#create"
      get "/meeting_slots", to: "meeting_slots#index"
      get "/all_meeting_slots", to: "meeting_slots#all"
      get "/family_unavailabilities", to: "family_unavailabilities#index"
      post "/family_unavailabilities", to: "family_unavailabilities#create"
      delete "/family_unavailabilities/:meeting_slot_id", to: "family_unavailabilities#destroy", as: "family_unavailability_meeting_slot"
      patch "/family_unavailabilities/:family_id", to: "family_unavailabilities#update", as: "family_unavailability_family"
      post "/schedules/:id", to: "schedules#create", as: "schedule"
      get "/schedules/:id",to: "schedules#show"
      patch "/schedules/:id", to: "schedules#update"
      get "/class_rooms", to: "class_rooms#index"
      post "/users/parent", to: "users#create_parent"
      get "/admin/users", to: "admin#index"
      post "/admin/teachers", to: "admin#create_teacher"
      post "/admin/parents", to: "admin#create_parent"
      delete "/admin/parents/bulk_destroy", to: "admin#bulk_destroy"
      delete "/admin/teachers/bulk_destroy", to: "admin#bulk_teacher_destroy"
      delete "/admin/teachers/:id", to: "admin#destroy", as: "admin_teachers_destroy"
      delete "/admin/parents/:id", to: "admin#destroy", as: "admin_parents_destroy"
      get "/admin/parents/:id", to: "admin#show_parent", as: "admin_parents_show"
      patch "/admin/parents/:id", to: "admin#update_parent", as: "admin_parents_update"
      patch "/admin/teachers/:id", to: "admin#update_teacher", as: "admin_teachers_update"
      resources :families, only: :show, as: "family"
      get "child_list", to: "children#index"
      get "/children/unassigned", to: "children#unassigned"
      post "/password_resets", to: "password_resets#create"
      patch "/password_resets/:token", to: "password_resets#update", as: "password_resets_token"
      get "/assignment_stats", to: "assignment_stats#index"
      post "/assignments", to: "assignments#create"
      get "/google_auth/connect", to: "google_auth#connect"
      get "/google_auth/callback", to: "google_auth#callback"
      get "/google_auth/status", to: "google_auth#status"
      post "/google_calendar/:id", to: "google_calendar#create"
      get "/teacher_exports", to: "teacher_exports#index"
      
    end
  end
end
