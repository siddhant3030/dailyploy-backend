defmodule DailyployWeb.UserStoriesView do
  use DailyployWeb, :view

  alias DailyployWeb.{
    UserView,
    TaskStatusView,
    TaskListTasksView,
    RoadmapChecklistView
  }

  def render("show.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      task_lists_id: user_stories.task_lists_id
    }
  end

  def render("task_list_view.json", %{user_stories: user_stories}) do
    %{
      id: user_stories.id,
      name: user_stories.name,
      description: user_stories.description,
      is_completed: user_stories.is_completed,
      owner_id: user_stories.owner_id,
      priority: user_stories.priority,
      due_date: user_stories.due_date,
      task_status: render_one(user_stories.task_status, TaskStatusView, "status.json"),
      owner: render_one(user_stories.owner, UserView, "user.json"),
      roadmap_id: user_stories.task_lists_id,
      task_lists: render_many(user_stories.task_lists_tasks, TaskListTasksView, "user_show.json"),
      checklist:
        render_many(user_stories.roadmap_checklist, RoadmapChecklistView, "user_show.json")
    }
  end
end
