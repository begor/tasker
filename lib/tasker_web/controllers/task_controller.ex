defmodule TaskerWeb.TaskController do
  use TaskerWeb, :controller

  def sort(conn, params) do
    case Tasker.Sorting.sort(params["tasks"]) do
      {:ok, sorted_tasks} -> json(conn, sorted_tasks)
      {:error, reason} -> conn |> put_status(400) |> json(%{"error" => reason})
    end
  end

  def bash(conn, params) do
    case Tasker.Sorting.sort(params["tasks"]) do
      {:ok, sorted_tasks} -> text(conn, Tasker.Formatting.bash(sorted_tasks))
      {:error, reason} -> conn |> put_status(400) |> json(%{"error" => reason})
    end
  end
end
