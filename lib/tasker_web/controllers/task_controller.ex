defmodule TaskerWeb.TaskController do
  use TaskerWeb, :controller

  def sort(conn, _params) do
    text(conn, "Sorting...")
  end

  def bash(conn, _params) do
    text(conn, "Texting...")
  end
end
