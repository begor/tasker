defmodule Tasker.Formatting do
  @doc """
    Formates given tasks list into bash script with (optionally) given shebang.
  """
  def bash(tasks, shebang \\ "#!/usr/bin/env bash") do
    commands = tasks
    |> Enum.map(&Map.get(&1, "command"))
    |> Enum.join("\n")

    "#{shebang}\n#{commands}"
  end
end