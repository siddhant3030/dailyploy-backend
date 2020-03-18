defmodule DailyployWeb.Router do
  use DailyployWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :jwt_authenticated do
    plug Auth.Pipeline
  end

  scope "/api/v1", DailyployWeb do
    resources "/enquires", EnquiryController, only: [:create]
    post "/sign_up", SessionController, :sign_up
    post "/sign_in", SessionController, :sign_in
    post "/google_auth", SessionController, :google_auth
    post "/google_signin", SessionController, :google_auth_sign_in
    get "/forgot_password", PasswordRecoveryController, :generate_email
  end

  scope "/api/v1", DailyployWeb do
    get "/token_details/:token_id", TokenDetailsController, :index
    get "/roles", RoleController, :index
  end

  scope "/api/v1", DailyployWeb do
    pipe_through :jwt_authenticated

    post "/add_workspace", NewWorkspaceController, :add_user_workspace
    get "/tasks/:id", TaskController, :show
    post "/tasks/:task_id/start-tracking", TimeTrackingController, :start_tracking
    put "/tasks/:task_id/stop-tracking", TimeTrackingController, :stop_tracking
    resources "/comment", TaskCommentController
    put "/tasks/:task_id/edit_tracked_time/:id", TimeTrackingController, :edit_tracked_time
    delete "/tasks/:task_id/delete/:id", TimeTrackingController, :delete

    get "/logged_in_user", UserController, :show
    resources "/users", UserController

    resources "/workspaces", WorkspaceController, only: [:index] do
      get "/running_task", TaskController, :running_task
      resources "/members", MemberController, only: [:index, :show, :update, :delete]
      resources "/tags", TagController, only: [:create, :update, :delete, :index, :show]
      resources "/workspace_settings", UserWorkspaceSettingsController, only: [:update]

      post "/workspace_settings/adminship_removal",
           UserWorkspaceSettingsController,
           :remove_workspace_admin

      post "/workspace_settings/add_admin", UserWorkspaceSettingsController, :add_workspace_admin

      resources "/task_category", TaskCategoryController,
        only: [:create, :delete, :index, :show, :update]

      post "/workspace_settings/daily_status_mail_settings",
           UserWorkspaceSettingsController,
           :daily_status_mail_settings

      put "/update_daily_status_mail",
          UserWorkspaceSettingsController,
          :update_daily_status_mail

      get "/workspace_settings/show_daily_status_mail",
          UserWorkspaceSettingsController,
          :show_daily_status_mail

      resources "/reports", ReportController, only: [:index]
      get "/csv_download", ReportController, :csv_download
      get "/project_summary_report", ReportController, :project_summary_report
      get "/user_summary_report", ReportController, :user_summary_report
      get "/category_summary_report", ReportController, :categories_summary_report
      get "/priority_summary_report", ReportController, :priorities_summary_report

      resources "/projects", ProjectController do
        resources "/tasks", TaskController, only: [:index, :create, :update, :delete]
        put "/make_as_complete/:id", TaskController, :task_completion
        resources "/contact", ContactController, only: [:show, :create, :update, :delete, :index]
      end

      delete "/projects", ProjectController, :delete
    end

    # resources "/projects", ProjectController
    resources "/invitations", InvitationController
    get "/workspaces/:workspace_id/project_tasks", WorkspaceController, :project_tasks
    get "/workspaces/:workspace_id/user_tasks", WorkspaceController, :user_tasks
  end
end
