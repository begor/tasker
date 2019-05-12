defmodule Tasker.Formatting do
  def bash(tasks, shebang \\ "#!/usr/bin/env bash") do
    commands = tasks
    |> Enum.map(&Map.get(&1, "command"))
    |> Enum.join("\n")

    "#{shebang}\n#{commands}"
  end
end