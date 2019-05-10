defmodule Tasker.Operations do
  def sort(tasks) do
    result = tasks
    |> build_graph
    |> toposort
    |> validate_graph
    |> format_tasks
  end

  defp build_graph(tasks) do
    tasks 
    |> Enum.map(&Map.put_new(&1, "requires", []))
    |> Enum.map(fn task -> {task["name"], task} end) 
    |> Map.new
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

  defp validate_graph({graph, sorted_order, postvisit_map}) do
    # TODO: check neighbors, check cycles
    {:ok, graph, sorted_order}
  end

  defp format_tasks({:ok, graph, sorted_order}) do
    Enum.map(
      sorted_order,
      fn task_name -> 
        task = graph[task_name]
        %{"name" => task["name"], "command" => task["command"]}
      end
    )
  end
  defp format_tasks({:error, reason}) do
    {:error, reason}
  end
end