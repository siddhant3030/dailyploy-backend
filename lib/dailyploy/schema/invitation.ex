defmodule Dailyploy.Schema.Invitation do 
    use Ecto.Schema
    import Ecto.Changeset
    alias Dailyploy.Schema.Workspace
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.User

    schema "invitations" do
        field :email, :string
        field :token, :string
        field :status, InviteStatusTypeEnum
        belongs_to :workspace, Workspace
        belongs_to :project, Project        
        belongs_to :sender, User

        timestamps()
    end

    def changeset(invitation, attrs) do 
        invitation
        |> cast(attrs, [:email, :status, :token])
        |> validate_required([:email, :status])
        |> validate_format(:email, ~r/^[A-Za-z0-9._%+-+']+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/)        
        |> genToken(attrs)
        |> unique_constraint(:email)
        |> put_assoc(:workspace, attrs["workspace"])
        |> put_assoc(:project, attrs["project"])
        |> put_assoc(:sender,   attrs["sender"])
        |> validate_required([:workspace, :project, :sender])
    end  
    
    defp genToken(changeset, attrs) do
        %{"email" => email, "project" => %Project{name: project_name} , "workspace" => %Workspace{name: workspace_name}} = attrs
        str = "#{email}#{project_name}#{workspace_name}"
        token =  String.length(str)|> :crypto.strong_rand_bytes |> Base.encode32 |> binary_part(0, String.length(str)) # workspace id project_id email _id unique id
        put_change(changeset, :token, token)
    end   
end   