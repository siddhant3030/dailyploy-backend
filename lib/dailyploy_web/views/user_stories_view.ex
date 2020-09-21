defmodule DailyployWeb.UserStoriesView do
  use DailyployWeb, :view

  alias DailyployWeb.{
    UserView,
    TaskStatusView
  }

  def render("show.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      task_lists_id: user_stories.task_lists_id
    }
  end
end
