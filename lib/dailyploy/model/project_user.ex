defmodule Dailyploy.Model.ProjectUser do
  alias Dailyploy.Repo
  alias Dailyploy.Schema.ProjectUser

  def list_project_users() do
    Repo.all(ProjectUser)
  end

  def get_project_user!(id), do: Repo.get(ProjectUser, id)

  def create_project_user(attrs \\ %{}) do
    %ProjectUser{}
    |> ProjectUser.changeset(attrs)
    |> Repo.insert()
  end

  def update_project_user(projectuser, attrs) do
    projectuser
    |> ProjectUser.changeset(attrs)
    |> Repo.update()
  end

  def delete_project_user(projectuser) do
    Repo.delete(projectuser)
  end
end
