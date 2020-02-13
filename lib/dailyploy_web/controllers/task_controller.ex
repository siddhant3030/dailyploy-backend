defmodule DailyployWeb.TaskController do
  use DailyployWeb, :controller

  alias Dailyploy.Repo
  alias Dailyploy.Model.Task, as: TaskModel
  alias Dailyploy.Schema.Task
  alias Dailyploy.Helper.Firebase
  plug Auth.Pipeline

  action_fallback DailyployWeb.FallbackController

  @spec index(Plug.Conn.t(), any) :: Plug.Conn.t()
  def index(conn, %{"project_id" => project_id}) do
    tasks =
      TaskModel.list_tasks(project_id)
      |> Repo.preload([:members, :owner, :category, :time_tracks])

    render(conn, "index.json", tasks: tasks)
  end

  @spec create(Plug.Conn.t(), map) :: Plug.Conn.t()
  def create(conn, %{"project_id" => project_id, "task" => task_params}) do
    user = Guardian.Plug.current_resource(conn)

    task_params =
      task_params
      |> Map.put("project_id", project_id)
      |> Map.put("owner_id", user.id)

    case TaskModel.create_task(task_params) do
      {:ok, %Task{} = task} ->
        Firebase.insert_operation(
          Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
          "task_created"
        )

        render(conn, "show.json", task: task |> Repo.preload([:owner, :category, :time_tracks]))

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def update(conn, %{"id" => id, "task" => task_params}) do
    task = TaskModel.get_task!(id)

    case TaskModel.update_task_status(task, task_params) do
      {:ok, %Task{} = task} ->
        Firebase.insert_operation(
          Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
          "task_update"
        )

        render(conn, "show.json", task: task |> Repo.preload([:owner, :category, :time_tracks]))

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def task_completion(conn, %{"id" => id, "task" => task_params}) do
    task = TaskModel.get_task!(id)

    case TaskModel.mark_task_complete(task, task_params) do
      {:ok, %Task{} = task} ->
        Firebase.insert_operation(
          Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
          "task_completed"
        )

        render(conn, "show.json", task: task |> Repo.preload([:owner, :category, :time_tracks]))

      {:error, task} ->
        conn
        |> put_status(422)
        |> render("changeset_error.json", %{errors: task.errors})
    end
  end

  def show(conn, %{"id" => id}) do
    task = TaskModel.get_task!(id) |> Repo.preload([:members, :owner, :category, :time_tracks])

    render(conn, "task_with_user.json", task: task)
  end

  def delete(conn, %{"id" => id}) do
    user = Guardian.Plug.current_resource(conn)
    task = TaskModel.get_task!(id)

    with false <- is_nil(task) do
      if user.id == task.owner_id do
        case TaskModel.delete_task(task) do
          {:ok, %Task{} = task} ->
            Firebase.insert_operation(
              Poison.encode(task |> Repo.preload([:project, :owner, :category, :time_tracks])),
              "task_deleted"
            )

            render(conn, "deleted_task.json", task: task |> Repo.preload([:owner]))

          {:error, task} ->
            conn
            |> put_status(422)
            |> render("changeset_error.json", %{errors: task.errors})
        end
      else
        conn
        |> put_status(403)
        |> json(%{"task_owner" => false})
      end
    else
      true ->
        conn
        |> put_status(404)
        |> json(%{"resource_not_found" => true})
    end
  end
end
