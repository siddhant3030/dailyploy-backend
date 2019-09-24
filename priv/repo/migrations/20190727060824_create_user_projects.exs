defmodule Dailyploy.Repo.Migrations.CreateUserProjects do
  use Ecto.Migration

  def change do
    create table(:user_projects) do
      add :user_id, :integer
      add :project_id, :integer

      timestamps()
    end

    create unique_index(:user_projects, [:user_id, :project_id],
      name: :unique_index_for_user_and_project_in_user_project
    )
  end
end
