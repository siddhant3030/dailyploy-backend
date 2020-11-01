defmodule Dailyploy.Model.Analysis do
    alias Dailyploy.Repo
    import Ecto.Query
    
    alias Dailyploy.Schema.Task
    alias Dailyploy.Schema.Project
    alias Dailyploy.Schema.TaskListTasks
    alias Dailyploy.Schema.TaskLists
    alias Dailyploy.Schema.UserProject
    alias Dailyploy.Schema.UserTask
    alias Dailyploy.Model.Task, as: TaskModel
    alias Dailyploy.Model.TaskListTasks, as: TLTModel
    
    def get_all_tasks(project_id, start_date, end_date) do
     
      dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date)
      roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date)
  
      total_time_spent =
        Enum.map(dashboard_tasks, fn x -> x.time_tracks end)
        #can use map_jooin
        |> Enum.concat()
        |> Enum.reduce(0, fn y, acc -> acc + y.duration end)
      
        
      # #totdal dashboard task  
      total_task_count = Enum.count(dashboard_tasks) + Enum.count(roadmap_tasks, fn task -> task.task_id == nil end)
  
      completed_tasks = Enum.count(dashboard_tasks, fn task -> task.is_complete == true end)

      %{"completed_tasks" => completed_tasks, "total_tasks" => total_task_count, "total_time_spent" => total_time_spent}
    end

    def get_all_members(project_id) do
      query =
        from projectuser in UserProject,
        where: projectuser.project_id == ^project_id,
        select: projectuser
      
      Repo.all(query) |> Enum.count()
    end

    def get_top_5_members(project_id, start_date, end_date) do 
      # dashboard_tasks = get_dashboard_tasks(project_id, start_date, end_date) |>  Repo.preload(owner: [:tasks] )
      # roadmap_tasks = get_roadmap_tasks(project_id, start_date, end_date) |>  Repo.preload(owner: [:tasks] )
       
      query =
        from projectuser in UserProject,
        where: projectuser.project_id == ^project_id,
        select: projectuser.user_id
      
      x = Repo.all(query)

      query1 =
      from user_tasks in UserTask,
      where: user_tasks.user_id in ^x,
      select: user_tasks

      a = Repo.all(query1) |> Repo.preload([user: [:user_workspace_settings], task: [:time_tracks]]) 
      b = Enum.map(a, fn x -> x.task end) 
          |> Enum.filter(fn x -> x.is_complete == true end) 
          |>  Enum.group_by(fn x -> x.owner_id end) 
          |> Enum.map(fn {user_id, tasks} -> %{user_id => tasks |> Enum.count()} end)
      
      member_time = Enum.map(a, fn x -> x.task end) 
          |> Enum.group_by(fn x -> x.owner_id end) 
          |> Enum.map(fn {user_id, tasks} -> %{user_id => tasks |> Enum.map(fn x -> x.time_tracks end) 
          |> Enum.concat() 
          |> Enum.reduce(0, fn y, acc -> acc + y.duration end)} end) 
      
      r = Enum.map(a, fn x -> x.user end) 
          |>  Enum.group_by(fn x -> x.id end)  
          |> Enum.map(fn {user_id, details} -> %{user_id => [details |> List.first()] 
          |> Enum.map(fn x -> %{"provider_img" => x.provider_img, "expense" => x.user_workspace_settings |> Enum.map(fn x -> x.hourly_expense end)} end) }  end)

          z = Enum.concat(b, r) |> Enum.concat(member_time)

          IO.inspect(z)
    end
    
    defp get_dashboard_tasks(project_id, start_date, end_date) do 
       query =
        from task in Task,
        where: task.project_id == ^project_id and task.updated_at > ^start_date and task.updated_at < ^end_date, 
        select: task
        
        Repo.all(query) |> Repo.preload(:time_tracks)
    end
    
    defp get_roadmap_tasks(project_id, start_date, end_date) do 
      query =
        from tasklist in TaskLists,
        where: tasklist.project_id == ^project_id, 
        select: tasklist
        
        task_lists = Repo.all(query) |> Repo.preload(:user_stories)

        task_list_ids = Enum.map(task_lists, fn task_list -> task_list.id end)

        userstory_ids = Enum.map(task_lists, fn task_list -> task_list.user_stories |> Enum.map(fn item -> item.id end ) end)
        userstories_ids = Enum.concat(userstory_ids)

        preload_query_1 = tlt_query(task_list_ids, start_date, end_date)
        preload_query_2 = userstory_query(userstories_ids, start_date, end_date)
  
        preloaded_tasks = task_lists |> Repo.preload([
            task_list_tasks: preload_query_1,
            user_stories: [ task_lists_tasks: preload_query_2 ]
          ])

        roadmap_tasks = Enum.map(preloaded_tasks, fn task_list -> task_list.task_list_tasks end)  
          |> Enum.concat() 
          |> Enum.filter(fn task -> task.task_id == nil end)

        userstory_tasks = Enum.map(preloaded_tasks, fn task_list -> task_list.user_stories  end)
          |> Enum.concat()
          |> Enum.map(fn user_story -> user_story.task_lists_tasks  end)
          |> Enum.concat()
          |> Enum.filter(fn task -> task.task_id == nil end)

       Enum.concat(roadmap_tasks, userstory_tasks)
    end

    defp tlt_query(task_list_ids, start_date, end_date) do 
      query = 
        from task in TaskListTasks,
        where: task.task_lists_id in ^task_list_ids and task.updated_at > ^start_date and task.updated_at < ^end_date,  
        select: task
    end

    defp userstory_query(userstories_ids, start_date, end_date) do 
      query = 
        from task in TaskListTasks,
        where: task.user_stories_id in ^userstories_ids and task.updated_at > ^start_date and task.updated_at < ^end_date,  
        select: task
    end

end
