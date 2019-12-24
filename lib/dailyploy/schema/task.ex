defmodule Dailyploy.Schema.Task do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  alias Dailyploy.Repo
  alias Dailyploy.Schema.Project
  alias Dailyploy.Schema.User
  alias Dailyploy.Schema.TaskCategory
  alias Dailyploy.Schema.TimeTracking
  alias Dailyploy.Schema.WorkspaceTaskCategory

  schema "tasks" do
    field :name, :string
    field :start_datetime, :utc_datetime
    field :end_datetime, :utc_datetime
    field :comments, :string

    belongs_to :owner, User
    belongs_to :project, Project
    has_many :time_tracks, TimeTracking
    many_to_many :members, User, join_through: "user_tasks", on_replace: :delete
    belongs_to :category, TaskCategory
    timestamps()
  end

  @doc false
  def changeset(task, attrs) do
    task
    |> cast(attrs, [
      :name,
      :start_datetime,
      :end_datetime,
      :comments,
      :project_id,
      :owner_id,
      :category_id
    ])
    |> validate_required([:name, :start_datetime, :end_datetime, :project_id, :owner_id])
    |> assoc_constraint(:owner)
    |> assoc_constraint(:project)
    |> put_task_members(attrs["member_ids"])
  end

  def update_changeset(task, attrs) do
    task
    |> Repo.preload([:members])
    |> cast(attrs, [:name, :start_datetime, :end_datetime, :comments, :project_id, :category_id])
    |> assoc_constraint(:project)
    |> put_task_members(attrs["member_ids"])
  end

  defp put_task_members(changeset, members) do
    members = Repo.all(from(user in User, where: user.id in ^members))

    put_assoc(changeset, :members, Enum.map(members, &change/1))
  end
end
