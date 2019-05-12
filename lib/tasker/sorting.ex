defmodule Tasker.Sorting do
  def sort(nil) do
    {:error, "No tasks provided"}
  end
  def sort(tasks) do
    graph = tasks
    |> build_graph
    |> validate_graph

    case graph do
      {:ok, graph} -> graph |> toposort |> check_cycles |> format_tasks
      err -> err
    end
  end

  defp build_graph(tasks) do
    tasks 
    |> Enum.map(&Map.put_new(&1, "requires", []))
    |> Enum.map(fn task -> {task["name"], task} end) 
    |> Map.new
  end

  defp validate_graph(graph) do
    failed_node = graph
    |> Enum.drop_while(fn {node_name, node} -> 
          Enum.all?(node["requires"], fn req -> req != node_name && Map.has_key?(graph, req) end)
        end)
    |> Enum.at(0)

    if failed_node == nil do
      {:ok, graph}
    else 
      {:error, "Invalid requires in task #{elem(failed_node, 0)}"}
    end
  end

  defp toposort(graph) do
    sorted = []
    visited = MapSet.new
    postvisit_map = Map.new
    clock = 0

    {sorted, postvisit_map, _, _} = Enum.reduce(
      graph,
      {sorted, postvisit_map, visited, clock},
      fn {node_name, _}, {sorted, postvisit_map, visited, clock} -> 
        toposort(graph, node_name, sorted, postvisit_map, visited, clock)
      end
    )

    {graph, sorted, postvisit_map}
  end
  defp toposort(graph, node_name, sorted, postvisit_map, visited, clock) do
    if MapSet.member?(visited, node_name) do
      {sorted, postvisit_map, visited, clock}
    else 
      visited = MapSet.put(visited, node_name)

      {sorted, postvisit_map, visited, clock} = Enum.reduce(
        graph[node_name]["requires"],
        {sorted, postvisit_map, visited, clock},
        fn requirement, {sorted, postvisit_map, visited, clock} -> 
          toposort(graph, requirement, sorted, postvisit_map, visited, clock)
        end)

      new_clock = clock + 1
      {sorted ++ [node_name], Map.put_new(postvisit_map, node_name, new_clock), visited, new_clock}
    end
  end

  defp check_cycles({graph, sorted_order, postvisit_map}) do
    is_acyclic = Enum.all?(
      graph,
      fn {node_name, node} -> 
        my_postivisit = postvisit_map[node_name]
        Enum.all?(node["requires"], fn req -> postvisit_map[req] < my_postivisit end)
      end
    )

    if is_acyclic do
      {:ok, graph, sorted_order}
    else
      {:error, "Detected cycle in tasks requires"}
    end    
  end

  defp format_tasks({:ok, graph, sorted_order}) do
    {:ok, Enum.map(
      sorted_order,
      fn task_name -> 
        task = graph[task_name]
        %{"name" => task["name"], "command" => task["command"]}
      end
    )}
  end
  defp format_tasks({:error, reason}) do
    {:error, reason}
  end
end